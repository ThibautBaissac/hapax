## Philosophy

### 1. Exploration Over Conclusion

* Never rush to conclusions.
* Keep exploring until a solution emerges naturally from the evidence.
* If uncertain, continue reasoning indefinitely.
* Question every assumption and inference.

### 2. Depth of Reasoning

* Engage in extensive contemplation (minimum 10,000 characters).
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
* The application runs on `http://localhost:3003`.

### Testing

* Use Minitest for all unit tests.
* Tests must be comprehensive and cover as many edge cases as possible.
* Prefer using the `factories.rb` file rather than YAML fixtures to instantiate models.
* Follow Rails testing best practices (e.g., naming conventions, setup/teardown patterns).
* Run tests via `rails test path/to/test/file.rb`.

---

## Views and Forms

### General Guidelines

* Use Simple Form for all forms.
* Utilize existing inputs stored under `views/shared` whenever possible.
* Maintain consistency in structure and styling across views.
* Ensure views support dark mode and adhere to the color palette defined in `config/tailwind.config.js`.
* Split views into partials aggressively to improve readability and maintainability.
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
* Avoid `change_column` on large tables; write separate `up`/`down` methods if data transformation is needed.
* Add indexes for foreign keys (e.g., `add_index :comments, :article_id`).
* Use `add_reference` for foreign keys (e.g., `add_reference :comments, :article, foreign_key: true`).
* When renaming columns or tables, consider backward compatibility for large production databases.
* Mark irreversible migrations explicitly using `raise ActiveRecord::IrreversibleMigration` in `def down` when necessary.

---

## Translations

* If new translations are added, update both `fr.yml` and `en.yml` files).
