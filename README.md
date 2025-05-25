# Caro Diario

This app was released in 2021 but when Apple published Journal, I decide to delete it. Now, it's a project where I liked to do some interesting experiments for learning purposes.

# Pending work

- Update TCA and Sharing. Considering use sharing-grdb instead CoreData

The last big update was Tuist and app has some problems that I need to fix it.

- [x] Splash
- [x] Onboarding
- [x] Settings
- [ ] Entries

# Install

```
tuist install
tuist cache --no-external-only
tuist generate
```

* Install tuist (you can compile the dependencies with tuist cache)
* For open project, just type in the console tuist generate