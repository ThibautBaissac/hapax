## Philosophy

### 1. Exploration Over Conclusion

* Never rush to conclusions.
* Keep exploring until a solution emerges naturally from the evidence.
* If uncertain, continue reasoning.
* Question every assumption and inference.

### 2. Depth of Reasoning

* Engage in extensive contemplation.
* Express thoughts in a natural, conversational internal monologue.
* Break down complex thoughts into simple, atomic steps.
* Embrace uncertainty and revision of previous thoughts.

### 3. Thinking Process

* Use short, simple sentences that mirror natural thought patterns.
* Express uncertainty and internal debate freely.
* Show work-in-progress thinking.
* Acknowledge and explore dead ends.
* Frequently backtrack and revise.

### 4. Persistence

* Value thorough exploration over quick resolution.

---

## Project Setup

### Environment

* Start the server with `bin/dev`.
* The application runs on `http://localhost:3000`.

### Testing

* Use Rspec for all unit tests.
* Tests must be comprehensive and cover as many edge cases as possible.
* Use factory bot for test data generation.
* Follow Rails testing best practices (e.g., naming conventions, setup/teardown patterns).
* Run tests via `rspec path/to/test/file.rb`.

---

## Views and Forms

### General Guidelines

* Maintain consistency in structure and styling across views.
* Split views into partials to improve readability and maintainability.
* Do not add any text directly in views without using translation files.
* If an icon is added, create it as a partial as well.

---

## Code Conventions

### Naming and Style

* Follow Ruby on Rails naming conventions (e.g., snake\_case for files and methods; CamelCase for classes).
* Respect SOLID principles for object-oriented design (e.g., single-responsibility, open/closed).
* Prioritize readability and maintainability over cleverness.

---

## Architecture

### MVC Principles

* Adhere strictly to the Rails MVC architecture.
* Keep controllers “skinny” by delegating complex business logic to models or service objects.
* Implement complex domain logic within service objects rather than controllers.

---

## Migrations

* Always generate migrations via Rails generators (e.g., `rails generate migration ...`) so timestamps remain accurate.
* Use modern Rails migration syntax (e.g., `t.string :name, null: false`).
* Add indexes for foreign keys (e.g., `add_index :comments, :article_id`).
* Use `add_reference` for foreign keys (e.g., `add_reference :comments, :article, foreign_key: true`).
* When renaming columns or tables, consider backward compatibility for large production databases.
* Mark irreversible migrations explicitly using `raise ActiveRecord::IrreversibleMigration` in `def down` when necessary.

---

## Translations

* If new translations are added, update `en.yml` file.
