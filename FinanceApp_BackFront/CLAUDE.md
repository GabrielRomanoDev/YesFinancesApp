# CLAUDE.md

> Guidance for any future Claude Code session working in this repository.
> Read this file first. It is written to give you full context with zero prior memory of the project.

---

## 1. Project Overview

**What it is:** A personal finance management app for iOS. It lets a user record and understand their spending across both **bank accounts (debit)** and **credit cards**, so people who live mostly on credit and people who live mostly on debit are equally served.

**The problem it solves:** Help the user *organize and understand* where their money goes, find opportunities to save, and plan ahead for future expenses. The long-term vision is a financial assistant — eventually with AI-driven insights and bank integration — but the near-term product is a solid, manual-entry expense tracker with dashboards.

**Target user:** Everyday Brazilian consumers who want clarity over monthly spending. The UI and all user-facing copy are currently in **Brazilian Portuguese (pt-BR)**.

**Naming status — IMPORTANT:** There is **no final product or company name yet**. The bundle identifier `com.yesCompany.YesFinancesApp`, the folder name `YesFinancesApp`, and the Xcode project name `FinanceApp_BackFront` are all **provisional placeholders**. Do not assume any of them is the official brand. There is also **no paid Apple Developer account yet**, which constrains anything requiring provisioning/capabilities (push, Sign in with Apple entitlements, TestFlight).

**Team:** Solo project (Gabriel Romano). Earlier git history and `xcuserdata` show other contributors (`yurialencar`, `usuario`) — that is historical only; the project is now maintained by one developer.

**This is a portfolio project** as well as a real product attempt. Code quality, clarity, and demonstrable architectural decisions matter. See [§11 Portfolio Context](#11-portfolio-context).

---

## 2. Tech Stack

| Layer | Choice |
|---|---|
| Language | Swift 5.0 |
| UI | UIKit (Storyboards + programmatic) **plus** SwiftUI (newer screens). Hybrid by design — see [§3](#3-architecture). |
| Minimum iOS | **16.0** |
| Xcode | **26.5** |
| Backend | Firebase — **Auth** + **Firestore** (Cloud Firestore is the system of record) |
| Auth providers | Email/Password, Google Sign-In (Apple Sign-In planned, stubbed) |
| Charts | `Charts` (Daniel Gindi / DGCharts) **via CocoaPods** |
| Animations | `Lottie` (lottie-spm) via SPM |
| Dependency managers | **Both** Swift Package Manager *and* CocoaPods are in use (see warning below) |

### Dependencies

**Via Swift Package Manager** (resolved in `FinanceApp_BackFront.xcworkspace/.../Package.resolved`):
- `firebase-ios-sdk` 11.12.0 (FirebaseCore, FirebaseAuth, FirebaseFirestore)
- `GoogleSignIn-iOS` 8.0.0
- `lottie-spm` 4.5.0
- (plus transitive: abseil, app-check, AppAuth, GoogleUtilities, gRPC, leveldb, nanopb, promises, swift-protobuf, etc.)

**Via CocoaPods** (`Podfile`, `Podfile.lock`):
- `Charts` 4.1.0 (pulls `SwiftAlgorithms` 1.0.0)
- CocoaPods version used: 1.15.2

> ⚠️ **Build target = the workspace, not the project.** Because CocoaPods is used, you **must** open/build `FinanceApp_BackFront.xcworkspace`. The `.xcworkspace` references both `FinanceApp_BackFront.xcodeproj` and `Pods/Pods.xcodeproj`. Building the bare `.xcodeproj` will fail to link `Charts`.

### Firebase configuration
- `GoogleService-Info.plist` lives at `FinanceApp_BackFront/GoogleService-Info.plist` and **is committed** to the repo.
- Firebase is initialized in `AppDelegate.application(_:didFinishLaunchingWithOptions:)` via `FirebaseApp.configure()`.
- Google Sign-In URL scheme is registered in `Info.plist` (`CFBundleURLTypes`).
- `Info.plist` declares the `remote-notification` background mode, but **push notifications are not implemented** (and would need a paid Apple account).

### Git
- Remote: `https://github.com/GabrielRomanoDev/YesFinancesApp.git`
- Main branch: `main`
- **No `.gitignore` exists** and **`Pods/` is committed** to the repo (~200 files). Consequences: a fresh clone builds without `pod install` (the Pods are already vendored), but `xcuserdata/` and `.DS_Store` also get tracked and show up as noise in `git status`. Flagged as a cleanup item — see [§5](#5-known-bugs--limitations).
- `GoogleService-Info.plist` is committed **intentionally** (see Firebase config above) — it holds client-side Firebase config, not a server secret. Real protection for a finance app must come from **Firestore security rules** (currently unconfigured — see [§5](#5-known-bugs--limitations)).

---

## 3. Architecture

**Pattern: MVVM + Repository, with a thin generic data-access service over Firestore.**

### Layers (data flows top to bottom)

```
View (UIViewController / SwiftUI View)
   │  owns / observes
ViewModel  (per screen; business logic, formatting, validation)
   │  reads & writes
Repository (singletons: in-memory cache of each entity list)
   │  persists via
FirestoreService.shared  (generic CRUD over Firestore, FirestoreObject protocol)
   │
Firebase Firestore  (system of record)
```

### Key building blocks

- **`FirestoreService`** (`Services/FirestoreService.swift`) — Singleton. Generic CRUD constrained to `FirestoreObject: Codable`. Every method dispatches its result back to the main thread via `completeOnMain`. Internally uses `async/await` (`Task { }`) but exposes a **`Result<T, Error>` callback API** to the rest of the app. Document path convention: `users/user_<uid>/<subCollection>/<objectId>`.
- **`FirestoreObject`** protocol — `Codable` + `var id: String`. All persisted models conform. This is the backbone of the generic data layer.
- **Repositories** (`Repositories/*.swift`) — Singletons (`static let shared`) holding a mutable in-memory `list: [T]` (and similar) for each entity: Transactions, CreditCardExpenses, BankAccounts, CreditCards, Categories. ViewModels read/mutate these directly. **There is no reactive binding (no Combine) at the repository layer** — repositories are plain mutable caches. Refresh is triggered explicitly (e.g. `HomeViewModel.getAllData`) and screens are told to reload via `NotificationCenter`.
- **`AuthenticationManager.shared`** (`Modules/Authentication/`) — Orchestrates all auth. Composes `EmailAuthService`, `GoogleAuthService`, `AppleAuthService` (stub), and `SessionManager`. Public API is `Result`-based: `login`, `loginWithGoogle`, `register`, `forgetPassword`, `logout`, `deleteCurrentAccount`, `updateUserInfo`, plus session helpers.
- **`SessionManager`** — Local session persistence. Stores the encoded `UserData` + last-login `Date` in `UserDefaults` (via `LocalStorageManager`). `isSessionValid()` requires a live `Auth.auth().currentUser` AND a last login within the **last 7 days** (`604800` seconds).
- **Navigation** — Storyboard-driven (`UINavigationController` + `UITabBarController`), with programmatic `push`/`present` in view controllers. Entry storyboard is `SplashViewController` (set in `Info.plist` → `UISceneStoryboardFile`). There is **no Coordinator layer**.
- **Concurrency** — `DispatchGroup` to fan-in multiple Firestore reads (see `HomeViewModel.getAllData`); `DispatchQueue.main.async` for UI; `async/await` only inside `FirestoreService`. ViewControllers/ViewModels consume **callbacks with `Result`**, not `async/await` directly.
- **Cross-screen events** — `NotificationCenter` with names centralized in `NotificationCenter/NotificationNames.swift` (e.g. `.updateTransactionsData`).

### Directory map (under `FinanceApp_BackFront/`)

```
Resources/            AppDelegate, SceneDelegate
Modules/Authentication/   AuthenticationManager, SessionManager, EmailAuthService,
                          Google/, Apple/ (stub), BiometricService (stub), Errors/LoginError
Services/             FirestoreService (generic CRUD), ExchangeRateService (currency — slated for removal)
Repositories/         Singleton in-memory caches per entity
Models/               Domain models; Enums/; Constants/ (Months, BanksList)
Screens/
  LoginScreens/       Splash, Main, Login, Register, ResetPassword(+Sent), ConfirmProfileInfo
  TabBarScreens/
    TabBarController/  Custom tab bar (has a SwiftUI component)
    HomeScreens/       Dashboard (collection view + cells: balances, accounts, cards, category graph)
    TransactionsScreens/ Listing, filtering (TransactionsFilterWorker), search, details, invoices
    AddScreens/        SwiftUI forms: TransactionFormScreen, CreditCardExpenseFormScreen
    MoreOptionsScreens/ BankAccounts, CreditCards, EditBankAccounts, EditCreditCards,
                        CategoriesGraph, Currency (slated for removal), Profile, MoreOptions
    GoalsScreens/      Goals list/info/edit (legacy UIKit — flagged for redesign)
  SharedModalScreens/  Reusable modals (accounts, categories, credit card, selection;
                       SwiftUI: SelectCategory/SelectSource/SelectInvoice, InputNumberOverTopView)
  SharedItens/         ⚠️ Older duplicate of several shared modals — see §5 (possible dead code)
  SharedCells/         Reusable table/collection cells
  ErrorScreens/        ErrorViewController
Extensions/           Date, String, Formatters, UIColor, UIImage, UIView, ViewController,
                      Alert, OptionalExtension, SwiftUI/ (View, UIApplication)
GlobalStrings/        globalStrings, FirebaseSubCollectionNames
NotificationCenter/   NotificationNames
Utils/                DataPersistence (LocalStorageManager, StorageKeys), StringError, UI resolver
```

### Per-screen folder convention

A screen is usually a folder containing subfolders: `View/`, `ViewModel/`, `Strings/`, and `Cell/` or `Cells/`. Follow this layout when adding a new screen.

---

## 4. Feature Map

### ✅ Stable / ready (safe to demo)
- **Authentication** — Email/Password + Google Sign-In, registration, password reset, 7-day session validation, account deletion (with Firestore data cleanup + reauth-required handling).
- **Home dashboard** — Balance cards (incomes / expenses / balance), bank accounts list, credit cards list, expenses-by-category graph (`Charts`), recent transactions, info-hiding toggle.
- **Transactions** — Monthly view, list transactions/invoices, search by description, advanced filtering, edit/delete.
- **Add (SwiftUI forms)** — `TransactionFormScreen` and `CreditCardExpenseFormScreen`: amount, date, category, source/account, income/expense, invoice-payment mode, monthly flag, observations; create & edit modes.
- **Credit cards & invoices** — View cards, invoice payment status, edit card details, invoice expense lists, installment tracking.
- **Bank accounts** — View, create, edit, standard-account flag, balance.

### 🔶 Works but wants rework (redesign UI + modernize code — do NOT treat as throwaway, treat as refactor candidates)
- **Goals** (`GoalsScreens/`) — Functional but legacy UIKit; flagged for a SwiftUI redesign with better UI.
- **User Profile** (`MoreOptionsScreens/ProfileViewController`) — Functional (edit info, delete account); wants UI/code refresh.
- Generally: the **"More" menu** and other older UIKit screens are considered visually dated and are redesign targets.

### 🗓️ Planned for v1 (future implementation — only build when asked)
- **Sign in with Apple** — `AppleAuthService` is a stub. (Needs a paid Apple account for the entitlement.)
- **Biometric authentication** — `BiometricService` is an empty placeholder.
- **Monthly spending limits per category** — new feature, not yet built.

### 🚫 Out of MVP — do NOT implement now
- **Currency converter** (`CurrencyViewController` + `ExchangeRateService` + `Mock/ExchangeRate.json`) — considered unnecessary for v1 and is **slated for removal**. Do not extend it.
- **AI assistant** (natural-language questions like "summarize my month", "where can I save?") — future, post-MVP.
- **Open Finance integration** (automatic expense import) — future, post-MVP.
- **English localization / second language** — desired eventually; influences the strings strategy (see [§7](#7-code-conventions)) but is **not** a current deliverable.
- **User-editable categories** — planned long-term; categories are currently hardcoded (see [§5](#5-known-bugs--limitations)).

---

## 5. Known Bugs & Limitations

> The user does **not** keep a formal bug tracker. The items below were found during code analysis and are documented here for **future correction** — do not fix them unprompted; raise them and confirm before acting.

### Dead / orphaned code (candidates for removal — confirm before deleting)
1. **`Models/TransactionsFilter.swift`** — **Not part of the build target** (absent from `project.pbxproj`), so its compile error is currently invisible. It references an **undefined type `ListedCategories`** (the real type is `TransactionCategory`, defined in `Models/TransactionCategory.swift` whose file header still says `ListedCategories.swift`). The struct is never instantiated. The live filtering logic lives in `TransactionsScreens/.../TransactionsFilterWorker.swift`, not here. → Likely delete, or repair + add to target if intended.
2. **`Cambio_Tela.swift`** and **`SplashScreenVC.swift`** (project root) — Empty boilerplate view controllers, unused. → Remove.
3. **`UserDataDTO`** (in `Models/UserData.swift`) — Declared but referenced only within its own file. The live model is `UserData`. → Likely remove.
4. **`HomeViewModel.addFieldToObjects()`** — A private one-off Firestore migration helper that is **never called**. → Remove.
5. **`EmailAuthService.setProfileinStorage()`** — Empty method, no callers. → Remove.
6. **`Screens/SharedItens/`** — Appears to be an older duplicate of modals now living under `Screens/SharedModalScreens/` (e.g. `AccountsModalViewModel`, `CategoriesModalViewController`, `SelectionModalScreen` appear in both trees). Verify which set is wired into the build before deleting either. ⚠️ Don't assume — check `project.pbxproj` membership first.

### Leftover scaffolding
7. **Core Data / CloudKit stack** in `AppDelegate` (`NSPersistentCloudKitContainer`, `saveContext`) is fully written, but the model `FinanceApp_BackFront.xcdatamodeld` is **empty** (`<elements/>`) and Core Data is **not used** (Firestore is the store). User confirmed **no intention to use Core Data** → remove the stack and the `.xcdatamodeld` when doing cleanup.
8. **Email verification** is commented out in `EmailAuthService.register` (lines ~53–59). Re-enable only if/when requested.

### Behavioral / quality limitations
9. **No automated tests** anywhere (no XCTest targets, no unit/UI tests). The app is validated manually.
10. **Hardcoded categories** — `HomeViewModel.getCategories()` hardcodes the 12 expense + 6 income categories (Portuguese names + asset image names + color indices). This blocks user-editable categories and second-language support until refactored. See also #16 (the positional `categoryIndex` that this hardcoding produces is the root cause of bugs #17 & #20).
11. **Hardcoded Portuguese strings** — User-facing copy lives in per-screen `enum …Strings` with literal pt-BR values. This is centralized but is **not** real localization (no runtime locale switching). See the improvement note in [§7](#7-code-conventions).
12. **File header / filename mismatches** — Several files have stale headers from when they were created via Xcode templates (e.g. `AccountTransaction.swift` header says `File.swift`; `UserData.swift` says `Profile.swift`; `TransactionCategory.swift` says `ListedCategories.swift`). Cosmetic; fix opportunistically.
13. **`print()`-based error handling** — Many Firestore failures are swallowed with `print(error)` and no user-facing feedback. The `//TODO: Adicionar no UserDefaults para sincronizar no futuro` markers (in `TransactionFormViewModel` and `CreditCardExpenseFormViewModel`) flag the intended offline-sync fallback that does not exist yet.

### Repo hygiene / security
14. **No `.gitignore`; `Pods/` is committed.** There is no ignore file at all, so `Pods/` (~200 files), `xcuserdata/`, and `.DS_Store` are all tracked. Upside: clones build without `pod install`. Downside: per-user Xcode state and OS junk pollute every diff. → When doing cleanup, add a Swift/Xcode/CocoaPods `.gitignore` and `git rm --cached` the vendored Pods + `xcuserdata` + `.DS_Store`. Confirm before doing this (it changes how clones bootstrap).
15. **Firestore security rules — authored, pending deploy.** `firestore.rules` now exists at the repo root, restricting every user to read/write only their own `users/user_<uid>/**` tree (owner-based isolation; everything else denied by default). ⚠️ **The file alone protects nothing** — rules take effect only once deployed to the Firebase project (via the console's Rules editor or `firebase deploy --only firestore:rules`). Verify the deployed rules in the Firebase console match this file before any real launch. **Security priority.**

### Logic / correctness bugs (found via static analysis — Jun 2026; verify at runtime)
> Two root causes drive several of these: **positional `categoryIndex`** (#16, #17, #20) and **dates stored as strings** (#21, #22, part of #24). Fixing each root once resolves the cluster.

16. **Positional `categoryIndex` is fragile (root cause).** Category is an `Int` indexing the hardcoded array in `HomeViewModel.getCategories()`, with magic `30+` indices for `fixedExpenses` (`CategoriesRepository`). Reordering/editing categories silently remaps every stored transaction. → A stable category ID (string/enum) fixes #17 & #20 and unblocks editable categories (#10) + localization.
17. **Category filter always uses the expense list.** `TransactionsScreens/.../FilteringSpecification.swift` → `CategorySpecification` compares against `CategoriesRepository.shared.expense(item.categoryIndex)` even for **income** transactions, so the category filter is wrong for incomes.
18. **Filter "incomes + expenses" selected together hides expenses.** Same file → `TypeSpecification.isSatisfied`: when both `types.incomes` and `types.expenses` are true it falls into `if types.incomes { return item.amount > 0 }` and excludes expenses. The "both selected" case should return all (like "neither selected").
19. **Crash: opening a form with no bank account / credit card.** `TransactionFormViewModel.setSourceID` and `CreditCardExpenseFormViewModel.setSourceID` do `…Repository.shared.list[index]` with no empty-list guard. The Add screen guards its buttons with `isEmpty`, but invoice payment pays from a bank account — creating a card + expense with **zero bank accounts** and then paying the invoice crashes on `list[0]`.
20. **Crash: `fatalError` on out-of-range category index.** `CategoriesRepository.expense(_:)`/`income(_:)` call `fatalError("Index out of bounds")`; any unexpected `categoryIndex` crashes the app instead of degrading gracefully.
21. **Dates stored as `"dd/MM/yyyy"` strings (correctness + architecture).** The display format is also the storage format (models + Firestore). Consequences: `FirestoreService.getLastObjectsList` `order(by: "date")` sorts lexicographically, not chronologically; ordering is redone client-side (`HomeViewModel.reordenateTransactions`); locale-fragile. → Persist `Date`/`Timestamp` (or ISO-8601), format only at the UI edge. (Note: `getLastObjectsList` is itself currently **dead code** — no callers — so remove or fix it alongside the migration.)
22. **`Date.setDate` silently falls back to *today* on an invalid day/month.** `Extensions/Date.swift`: `Calendar.current.date(from:) ?? Date()`. A card with `closingDay`/`dueDay = 31` in a 30-day month yields invalid components → today's date, corrupting invoice period/due dates. The `day > 31 → 28` clamp doesn't cover 29/30/31 in short months.
23. **"Transferência" button is a dead end.** `AddTransactionsView.swift` sets `showAddTransferView = true`, but its `.sheet` is commented out; the transfer feature is unimplemented yet the button ships in the UI.
24. **Lower-severity correctness nits.** `CreditCard.invoiceTotal` has a dead `if let transactionDate` (parses the date, never uses it; silently drops expenses whose date won't parse). `ValueSpecification` uses strict `>`/`<`, excluding exact min/max bounds. `PhoneNumberData.init?(formattedString:)` assumes the DDD is the first 2 digits (breaks if a country code is included). `HomeViewModel.reordenateTransactions`'s sort comparator returns `true` on parse failure (not a strict weak ordering).

> **Architecture note (not a bug, but flagged during analysis):** domain models reach into global singletons — `BankAccount.balance` and `CreditCard.invoiceTotal` read `…Repository.shared` from inside the struct. This couples models to global mutable state and blocks unit testing. Consider dependency injection / an observable store with the math in a service (see [§11](#11-portfolio-context)).

---

## 6. Essential Commands

> Always operate on the **workspace** (`FinanceApp_BackFront.xcworkspace`), scheme `FinanceApp_BackFront`. Run from the repo root: `/Users/gabrielromano/YesFinancesApp/FinanceApp_BackFront`.

### First-time setup (fresh clone)
1. `git clone https://github.com/GabrielRomanoDev/YesFinancesApp.git`
2. Open **`FinanceApp_BackFront.xcworkspace`** in Xcode 26.5 — **never** the `.xcodeproj` (see warning in [§2](#2-tech-stack)).
3. **No `pod install` needed normally** — `Pods/` is committed (see [§2](#2-tech-stack)). Only run it if you change the `Podfile`. SPM packages resolve automatically on first open.
4. `GoogleService-Info.plist` is already in the repo, so Firebase works out of the box.
5. Pick a simulator (iOS 16+) and run.

### Run the app on a simulator (CLI)
```bash
# Build, install, and launch on a booted simulator without opening Xcode:
xcrun simctl boot "iPhone 16" 2>/dev/null
xcodebuild \
  -workspace FinanceApp_BackFront.xcworkspace \
  -scheme FinanceApp_BackFront \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
# Then install/launch the built .app via `xcrun simctl install` / `launch`,
# or just use Xcode's Run button (Cmd-R) for the normal dev loop.
```
> For day-to-day development, running from Xcode (Cmd-R) is the expected path; the CLI build above is mainly the compile/safety check after edits.

### Build (iOS Simulator)
```bash
xcodebuild \
  -workspace FinanceApp_BackFront.xcworkspace \
  -scheme FinanceApp_BackFront \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```
> Adjust `name=` to a simulator that exists locally — list them with `xcrun simctl list devices available`. Use `-destination 'generic/platform=iOS Simulator'` if you only need a compile check without a specific device.

### Clean
```bash
xcodebuild \
  -workspace FinanceApp_BackFront.xcworkspace \
  -scheme FinanceApp_BackFront \
  clean
```

### Tests
- **None exist yet.** Once an XCTest target is added, run:
```bash
xcodebuild \
  -workspace FinanceApp_BackFront.xcworkspace \
  -scheme FinanceApp_BackFront \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test
```

### CocoaPods (only when touching Pod dependencies)
```bash
pod install          # after changing the Podfile (CocoaPods 1.15.2)
pod repo update      # if a spec can't be found
```

### Lint
- **No linter is configured** (no SwiftLint/SwiftFormat). Do not assume one. If introducing one, ask first (it adds a dependency/tooling step).

> There is **no CI/CD** configured and none planned right now.

---

## 7. Code Conventions

### Language
- **Everything in English** for identifiers — variables, functions, types, file names, **and comments**. No Portuguese in code.
- **Exception:** user-facing copy (the *values* inside `…Strings` enums) is Portuguese (pt-BR), because that is what the user sees. The *keys* stay English.

### Naming
- Types: `UpperCamelCase` (`BankAccount`, `LoginViewModel`).
- Properties/functions: `lowerCamelCase`.
- View controllers end in `ViewController`; view models end in `ViewModel`.
- Enums for cases use `lowerCamelCase` (`.income`, `.expense`, `.overdue`).
- Per-screen string enums are `lowerCamelCase` (`loginStrings`, `homeStrings`, `addStrings`) — note these begin lowercase, matching the existing pattern.

### Strings / localization
- All user-facing text goes through an `enum …Strings { static let key = "…" }`, **never** inline string literals in views. This is intentional so a second language can be added later, and so copy is centralized.
- Truly global copy lives in `GlobalStrings/globalStrings.swift`; Firestore subcollection names in `GlobalStrings/FirebaseSubCollectionNames.swift`.
- **Improvement the user is open to (suggest, don't silently change):** the plain-enum approach centralizes copy but does not give real runtime localization. When second-language support becomes real, migrate these enums to a **String Catalog (`.xcstrings`, Xcode 15+)** with `String(localized:)`, keeping the same call-site ergonomics while gaining actual per-locale resolution. A `pt-BR.lproj`/`Base.lproj` pair already exists for the Main storyboard, so the project is partway there.

### Data layer
- New persisted models conform to **`FirestoreObject`** (`Codable` + `id`).
- Go through **`FirestoreService.shared`** for all Firestore I/O; do not call Firestore APIs directly from view models.
- Subcollection names come from `firebaseSubCollectionNames.*`, never string literals.
- Public service/manager APIs expose **`Result<T, Error>` callbacks**; keep `async/await` encapsulated inside the service layer to match the existing style.

### File organization
- One screen = one folder with `View/`, `ViewModel/`, `Strings/`, `Cell(s)/` subfolders. Mirror the nearest existing screen when adding a new one.
- Match the surrounding file's comment density and idioms (most files are lightly commented).

---

## 8. Absolute Rules (NEVER do these)

1. **NEVER add a dependency** (CocoaPods pod or SPM package) **without asking first.**
2. **NEVER commit or push** any change without explicit confirmation from the user. (You may stage/show diffs; do not `git commit`/`git push` on your own.)
3. **NEVER write Portuguese in code** — identifiers and comments are English-only. (Portuguese only inside `…Strings` enum *values*.)
4. **NEVER introduce user-facing string literals** outside the `…Strings` enums.
5. **NEVER build against the bare `.xcodeproj`** — always the `.xcworkspace` (CocoaPods).
6. **NEVER expand the out-of-MVP features** (currency converter, AI, Open Finance, English localization, editable categories) unless explicitly asked. The currency converter is being removed, not extended.
7. **NEVER call Firestore directly** from view models/controllers — route through `FirestoreService`.
8. **NEVER assume the product/company name** — it is undefined; don't bake `YesFinances`/`yesCompany` into anything as if it were final.
9. **NEVER delete a file because it "looks unused"** without first checking `project.pbxproj` target membership and confirming with the user (several look-alike duplicates exist — see [§5](#5-known-bugs--limitations)).

---

## 9. Workflow Rules

- **Propose before implementing** non-trivial changes. Outline the approach, get a yes, then build.
- **Compile after changes.** After editing Swift, run a build (workspace + scheme, see [§6](#6-essential-commands)) to confirm it still compiles before reporting done. There are no tests to fall back on, so a clean build is the primary safety net.
- **Confirm before committing.** Show the diff; let the user commit, or commit only on explicit instruction. If you do commit on request and you're on `main`, branch first.
- **Keep changes scoped.** Don't bundle unrelated cleanup into a feature change; flag dead code / bugs separately (see the bug list in [§5](#5-known-bugs--limitations)) rather than fixing them inline without asking.
- **Respect the hybrid UI reality.** New screens can be SwiftUI; you don't need to convert existing UIKit screens to ship. When redesigning a flagged legacy screen (Goals, More menu, Profile), SwiftUI is the preferred direction.
- **Report honestly.** If a build fails, say so with the output. If you skipped a step, say so.

---

## 10. Firestore Data Model

> Cloud Firestore is the system of record. All user data is namespaced under a per-user document so a user can only ever touch their own tree (which is also what the security rules in [§5](#5-known-bugs--limitations) must enforce).

### Document path convention
```
users/user_<uid>/<subCollection>/<objectId>
```
- `<uid>` = the Firebase Auth UID.
- `<subCollection>` names come from `firebaseSubCollectionNames` (`GlobalStrings/FirebaseSubCollectionNames.swift`) — **never** hardcode these strings.
- `<objectId>` = each model's `id` (a `UUID().uuidString` generated client-side; profile is the exception).

### Subcollections (`firebaseSubCollectionNames`)
| Key | Collection name | Model | Notes |
|---|---|---|---|
| `transactions` | `transactions` | `AccountTransaction` | Debit/bank-account movements |
| `creditCardExpenses` | `creditCardExpenses` | `CreditCardExpense` | Credit-card movements (with installments) |
| `bankAccounts` | `bankAccounts` | `BankAccount` | |
| `creditCards` | `creditCards` | `CreditCard` | |
| `goals` | `goals` | `Goal` | Legacy UIKit feature |
| `profile` | `profile` | `UserData` | Single user-profile doc |
| `notUsed` | `NotUsed` | — | Placeholder; not a live collection |

### Persisted models (key fields)
All conform to `FirestoreObject` (`Codable` + `id`). Categories are **not** persisted — they are hardcoded in `HomeViewModel.getCategories()` and referenced by `categoryIndex` (see [§5](#5-known-bugs--limitations)).

- **`AccountTransaction`** — `id`, `desc`, `amount: Double`, `categoryIndex: Int`, `date: String`, `type: TransactionType` (`.income`/`.expense`), `month: MonthDate`, `isMonthly: Bool`, `attachmentUrl: String?`, `sourceId: String` (→ a `BankAccount.id`), `obs`. Conforms to the shared `Transactions` protocol.
- **`CreditCardExpense`** — same shape as above, plus `paymentStatus: PaymentStatus` and `installment: Installment` (`enabled: Bool`, `current: Int`, `total: Int`); `sourceId` → a `CreditCard.id`. Also conforms to `Transactions`.
- **`BankAccount`** — `id`, `desc`, `bank: Banks`, `overdraft: Double`, `standardAccount: Bool`, `obs`. `balance` is a **computed** property (sums `TransactionsRepository` entries with matching `sourceId`) — it is not stored. Conforms to `TransactionSource`.
- **`CreditCard`** — `id`, `desc`, `limit: Double`, `bank: Banks`, `closingDay: Int`, `dueDay: Int`, `standardCard: Bool`, `obs`. Invoice totals, billing periods, and payment status are computed from `CreditCardExpensesRepository`. Conforms to `TransactionSource`.
- **`Goal`** — `id`, `desc`, `imageName`, `savedAmount: Double`, `goalValue: Double`, `targetDate: String`; `daysToDate` / `remainingAmount` are computed.
- **`UserData`** (profile) — `id`, `name`, `email`, `phoneNumber: PhoneNumberData?`, `photoURL: URL?`; `userInfoIsSet` is computed. `PhoneNumberData` splits into `nationalCode`/`zoneCode`/`number` with E.164 + local formatting helpers. (`UserDataDTO` in the same file is dead — see [§5](#5-known-bugs--limitations).)

> **Conventions worth noting:** `date` is stored as a `String` (not a Firestore `Timestamp`) — formatting/parsing goes through the `Date`/`String` extensions in `Extensions/`. `month` is a structured `MonthDate` used for the monthly grouping the Transactions screen relies on. Account/card balances and invoice math are **derived at read time** from the repositories, never persisted — keep it that way so there is a single source of truth.

---

## 11. Portfolio Context

This is a portfolio piece; preserve and showcase the things that demonstrate deliberate engineering. The user asked for a recommendation on what to highlight — these are the strongest, genuinely-present angles:

1. **Generic, protocol-oriented data layer.** `FirestoreService` + `FirestoreObject: Codable` give a single, type-safe CRUD surface (`getObjectsList(forObjectType:)`, `setObject`, batched `setObjectsList`, cascading `deleteUserData`) reused across every entity. This is the cleanest part of the codebase — keep it generic; don't special-case it per model.
2. **Composable, multi-provider auth.** `AuthenticationManager` cleanly orchestrates `EmailAuthService` / `GoogleAuthService` / `AppleAuthService` / `SessionManager` behind one `Result`-based API, including real-world concerns: 7-day session validity, reauth-required handling on account deletion, and full Firestore data cleanup on delete. Good separation-of-concerns story.
3. **Pragmatic incremental UIKit→SwiftUI migration.** The app demonstrates introducing SwiftUI (the Add forms, shared SwiftUI modals, a SwiftUI tab-bar component) into a mature UIKit + Storyboard app via hosting — a realistic, employable skill, not a greenfield SwiftUI demo.
4. **Consistent layered structure.** View / ViewModel / Repository / Service separation with a uniform per-screen folder convention shows scalable organization.

**To make the portfolio story stronger** (suggest when relevant, don't do unprompted): add a focused **unit-test target** around the most logic-heavy, UI-free pieces — `SessionManager.isSessionValid`, `TransactionsFilterWorker`, balance aggregation in `HomeViewModel`, `PhoneNumberData` parsing/formatting. These are deterministic and would demonstrate testing discipline with minimal surface area. Pair that with the dead-code cleanup in [§5](#5-known-bugs--limitations) so a reviewer sees an intentional, tidy codebase.

---

## 12. Documented Next Steps (roadmap reference — do not implement unprompted)

**Near-term (the user's stated focus):**
1. Verify everything currently works end-to-end; triage and fix the bugs in [§5](#5-known-bugs--limitations).
2. Redesign legacy UIKit screens in SwiftUI — **Goals** and the **More** menu first, then **Profile**.
3. New feature: **monthly spending limits per category**.
4. **Sign in with Apple** (needs paid Apple account).
5. **Biometric authentication** (`BiometricService`).
6. Clean up dead code / leftover scaffolding (Core Data stack, orphaned files, duplicate modal trees).

**v1 polish:**
- Offline write fallback (the `//TODO: Adicionar no UserDefaults para sincronizar no futuro` markers): queue failed Firestore writes locally and sync later.
- User-facing error handling to replace silent `print()` failures.

**Post-MVP / future (explicitly out of current scope):**
- AI assistant for natural-language financial questions ("summarize my month", "where can I save?").
- Open Finance integration for automatic expense import.
- English (second language) — drives the String Catalog migration in [§7](#7-code-conventions).
- User-editable categories (requires de-hardcoding `HomeViewModel.getCategories`).

---

*Last updated 2026-06-20 from a full repository analysis. When project facts here drift from the code (names, versions, feature states), trust the code and update this file.*
