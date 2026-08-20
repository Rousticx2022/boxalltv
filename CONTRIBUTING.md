# Contributing to FrameTV

First off, thank you for considering contributing to FrameTV! 

## Branch Naming Conventions
Please use descriptive branch names following these prefixes:
- `feature/` - for new features (e.g., `feature/user-profile`)
- `bugfix/` - for bug fixes (e.g., `bugfix/cart-quantity-selector`)
- `hotfix/` - for urgent production fixes
- `refactor/` - for code refactoring
- `chore/` - for maintenance tasks (e.g., `chore/update-dependencies`)

## Commit Message Expectations
We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification. This leads to more readable messages that are easy to follow when looking through the project history.

**Format:**
```
<type>(<optional scope>): <description>

[optional body]

[optional footer(s)]
```

**Allowed Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, etc)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools and libraries

**Example:**
```
fix(reels): resolve issue where video uploads without selected music
```

## Pull Requests
1. Ensure your code passes all existing tests (`flutter test`).
2. Ensure you have not hardcoded any sensitive credentials. A pre-commit hook runs to prevent known secret formats from being committed.
3. Provide a clear description of the problem solved or the feature added.
