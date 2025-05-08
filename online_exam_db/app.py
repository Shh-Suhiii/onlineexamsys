from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from flask import send_file
from io import BytesIO
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

app = Flask(__name__)
CORS(app)

db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Macbook@2023",
    database="online_exam_db"
)
cursor = db.cursor(dictionary=True)

@app.route('/signup', methods=['POST'])
def signup():
    data = request.json
    email = data.get('email')
    password = data.get('password')
    role = data.get('role', 'student')

    if not email or not password:
        return jsonify({'error': 'Email and password required'}), 400

    try:
        cursor.execute("INSERT INTO users (email, password, role) VALUES (%s, %s, %s)", (email, password, role))
        db.commit()
        return jsonify({'message': 'Signup successful'}), 201
    except mysql.connector.IntegrityError:
        return jsonify({'error': 'User already exists'}), 409
    
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    cursor.execute("SELECT * FROM users WHERE email = %s AND password = %s", (email, password))
    user = cursor.fetchone()

    if user:
        role = user.get('role', 'student')
        return jsonify({'message': 'Login successful', 'role': role}), 200
    else:
        return jsonify({'error': 'Invalid credentials'}), 401

@app.route('/create_exam', methods=['POST'])
def create_exam():
    data = request.json
    title = data['title']
    subject = data['subject']
    duration = data['duration']
    total_marks = data['total_marks']
    questions = data['questions']

    cursor.execute("INSERT INTO exams (title, subject, duration, total_marks) VALUES (%s, %s, %s, %s)", 
        (title, subject, duration, total_marks))
    exam_id = cursor.lastrowid

    for q in questions:
        cursor.execute("""
            INSERT INTO questions (exam_id, question_text, option_a, option_b, option_c, option_d, correct_answer)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            exam_id, q['question'], q['options'][0], q['options'][1], q['options'][2], q['options'][3], q['answer']
        ))

    db.commit()
    return jsonify({'message': 'Exam created successfully', 'exam_id': exam_id})

@app.route('/get_exams', methods=['GET'])
def get_exams():
    cursor.execute("SELECT * FROM exams")
    exams = cursor.fetchall()
    return jsonify(exams)  # will return [] if no exams

@app.route('/get_questions/<int:exam_id>', methods=['GET'])
def get_questions(exam_id):
    cursor.execute("SELECT * FROM questions WHERE exam_id = %s", (exam_id,))
    questions = cursor.fetchall()
    return jsonify(questions)

@app.route('/submit_result', methods=['POST'])
def submit_result():
    data = request.json
    exam_id = data['exam_id']
    student_email = data['email']
    score = data['score']
    total = data['total']

    cursor.execute("""
        INSERT INTO results (exam_id, email, score, total_marks)
        VALUES (%s, %s, %s, %s)
    """, (exam_id, student_email, score, total))
    db.commit()

    return jsonify({'message': 'Result submitted successfully'})

@app.route('/get_results/<email>', methods=['GET'])
def get_results(email):
    cursor.execute("""
        SELECT r.*, e.title, e.subject 
        FROM results r
        JOIN exams e ON r.exam_id = e.exam_id
        WHERE r.email = %s
        ORDER BY r.submitted_at DESC
    """, (email,))
    results = cursor.fetchall()
    return jsonify(results)

@app.route('/get_all_results', methods=['GET'])
def get_all_results():
    cursor.execute("""
        SELECT r.*, e.title, e.subject 
        FROM results r
        JOIN exams e ON r.exam_id = e.exam_id
        ORDER BY r.submitted_at DESC
    """)
    results = cursor.fetchall()
    return jsonify(results)

@app.route('/')
def home():
    return "✅ Online Examination System API is running!"

@app.route('/request_password_reset', methods=['POST'])
def request_password_reset():
    data = request.json
    email = data.get('email')

    cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()

    if user:
        return jsonify({'message': 'OTP sent', 'otp': '1234'}), 200
    else:
        return jsonify({'error': 'Email not found'}), 404
    

@app.route('/reset_password', methods=['POST'])
def reset_password():
    data = request.json
    email = data.get('email')
    otp = data.get('otp')
    new_password = data.get('new_password')

    if otp == '1234':
        cursor.execute("UPDATE users SET password = %s WHERE email = %s", (new_password, email))
        db.commit()
        return jsonify({'message': 'Password updated successfully'}), 200
    else:
        return jsonify({'error': 'Invalid OTP'}), 400
    
@app.route('/admin_stats', methods=['GET'])
def admin_stats():
    cursor.execute("SELECT COUNT(*) FROM users WHERE role = 'student'")
    result = cursor.fetchone()
    total_students = result.get('COUNT(*)') if result else 0

    cursor.execute("SELECT COUNT(*) AS total FROM exams")
    result = cursor.fetchone()
    total_exams = result.get('total') if result else 0

    cursor.execute("SELECT AVG(score) AS average FROM results")
    result = cursor.fetchone()
    avg_score = round(result.get('average'), 2) if result and result.get('average') is not None else 0

    # Score distribution
    def count_range(query):
        cursor.execute(query)
        result = cursor.fetchone()
        return result.get('count') if result else 0

    low = count_range("SELECT COUNT(*) AS count FROM results WHERE score BETWEEN 0 AND 40")
    mid = count_range("SELECT COUNT(*) AS count FROM results WHERE score BETWEEN 41 AND 60")
    high = count_range("SELECT COUNT(*) AS count FROM results WHERE score BETWEEN 61 AND 80")
    top = count_range("SELECT COUNT(*) AS count FROM results WHERE score > 80")

    return jsonify({
        "total_students": total_students,
        "total_exams": total_exams,
        "average_score": avg_score,
        "distribution": {
            "0-40": low,
            "41-60": mid,
            "61-80": high,
            "81-100": top
        }
    })

@app.route('/export_results', methods=['GET'])
def export_results():
    cursor.execute("SELECT r.id, u.email, e.title, r.score FROM results r JOIN users u ON r.user_id = u.id JOIN exams e ON r.exam_id = e.exam_id")
    results = cursor.fetchall()

    buffer = BytesIO()
    pdf = canvas.Canvas(buffer, pagesize=letter)
    pdf.setFont("Helvetica", 12)
    y = 750

    pdf.drawString(30, y, "ID | Email | Exam Title | Score")
    y -= 20
    for row in results:
        pdf.drawString(30, y, f"{row[0]} | {row[1]} | {row[2]} | {row[3]}")
        y -= 20
        if y < 50:
            pdf.showPage()
            y = 750

    pdf.save()
    buffer.seek(0)
    return send_file(buffer, as_attachment=True, download_name="exam_results.pdf", mimetype='application/pdf')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)