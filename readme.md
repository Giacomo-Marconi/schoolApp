
# School Stats App - Flutter Application

School Stats is a Flutter application designed to help students track their grades, view subject averages, and manage their progress. 
The app has a simple interface that allows you to get everything at its best.


## Pages
The app has 4 main pages:

* **Login Page**: The login page allow you to log in with your user and therefore view and enter your grades and subjects

* **Home Page**: The home page allow you to see the averages divied by each subject. They are displayed in 3 different colors:
    * **red**: when the average is under 6
    * **yellow**: when the average is above 6 but under 8
    * **green**: when the average is above 8

* **Grades Page**: Lists all the grades with details such as subject, description, date, and grade.

* **Add Grade Page**: Allows users to add new grades by selecting a subject, entering a description, choosing a date, and selecting a grade.


## Features

- **Settings Page**: Provides an option to logout of the application.

- **Secure Storage**: To secrely store the autehntication token.

- **API Integration**: Communicates with a backend API developed in python with Flask to fetch subject, grade, and authentication.



## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Giacomo-Marconi/schoolApp
   cd schoolApp/school_stats
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

## Dependencies

- `flutter_secure_storage`: For securely storing the authentication token.
- `http`: For making HTTP requests to the backend API.

## API Endpoints used

- **Login**: `POST /api/login`
- **Fetch Subjects**: `GET /api/materie`
- **Fetch Grades**: `GET /api/voti`
- **Add Grade**: `POST /api/voti`
