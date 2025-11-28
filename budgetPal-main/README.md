# budget_pal

## User Story: Expense Management

As a user of the Budget Pal app,
I want to easily manage my personal expenses so that I can better understand and control my spending habits.

### What You Can Do with Budget Pal
- **Add Expenses:** Enter details for each expense, including a title (e.g., "Groceries"), the amount spent, the date of the expense, a category (like Food, Transport, or Entertainment), and an optional note for extra details.
- **View Expenses:** See a list of all your expenses, sorted by date or grouped by category, so you can quickly review your spending history.
- **Categorize Spending:** Assign each expense to a category to help you see where your money goes each month.
- **Track Totals:** Instantly view the total amount spent in each category, making it easy to spot trends and areas to save.
- **Edit or Delete:** If you make a mistake or need to update an expense, you can easily edit or remove it from your records.
- **Persistent Data:** All your expenses are saved securely, so your data is available every time you open the app.

### Example Use Case
> Sarah uses Budget Pal to track her daily expenses. She adds each purchase, categorizes it (e.g., "Coffee" under Food & Drink), and at the end of the month, she reviews her spending by category to find ways to save.

---

## Requirements
- Users must be able to create an account and log in securely.
- Users can add, edit, and delete expenses with details (title, amount, date, category, note).
- Expenses should be displayed in a list, sortable by date or category.
- The app should show total spending per category and overall.
- Data must persist between app sessions.
- The UI should be clean, intuitive, and responsive on all devices.
- Users should be able to log out and switch accounts.
- The app must be built using Flutter and Dart.
- The backend or persistent storage should support Oracle and Java integration if required.

---

## Technologies Used
- **Flutter**: For building cross-platform mobile applications.
- **Dart**: The programming language used with Flutter.
- **Oracle**: For backend database management (if integrated).
- **Java**: For backend services or integration with Oracle (if required).
- **Provider**: For state management (see `auth_provider.dart`).
- **Material Design**: For UI components and styling.
- **Local Storage**: (e.g., SharedPreferences or SQLite) for saving expenses data locally.
- **Custom Widgets**: Such as `expense_card.dart` and `expense_form.dart` for modular UI.

---

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
