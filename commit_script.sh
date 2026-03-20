#!/bin/bash
set -x

# 2. App Lifecycle
git checkout feature/app-lifecycle
git merge main -m "Merge main into feature/app-lifecycle" || echo "Merge failed or up to date"
git add EnglishApp/App/ EnglishApp/Features/Onboarding/Views/SplashScreenView.swift
git commit -m "feat: Implement app lifecycle and state management" || echo "No changes to commit"
git push origin feature/app-lifecycle

# 3. Onboarding Survey
git checkout feature/onboarding-survey
git merge main -m "Merge main into feature/onboarding-survey" || echo "Merge failed or up to date"
git add EnglishApp/Features/Onboarding/Models/ EnglishApp/Features/Onboarding/ViewModels/ EnglishApp/Features/Onboarding/Views/IntroView.swift EnglishApp/Features/Onboarding/Views/SurveyOptionRow.swift EnglishApp/Features/Onboarding/Views/SurveyView.swift EnglishApp/Features/Onboarding/Views/TypewriterText.swift
git commit -m "feat: Add onboarding survey views and viewmodels" || echo "No changes to commit"
git push origin feature/onboarding-survey

# 4. Network Sync
git checkout main
git checkout -b feature/network-sync || git checkout feature/network-sync
git merge main -m "Merge main" || true
git add EnglishApp/Core/Network/ Tests/
git commit -m "feat: Implement sync flow and network layer logic" || echo "No changes"
git push -u origin feature/network-sync

# 5. Home and Tabs
git checkout main
git checkout -b feature/home-tabs || git checkout feature/home-tabs
git merge main -m "Merge main" || true
git add EnglishApp/Features/Home/ EnglishApp/Features/MainTab/ EnglishApp/Features/Missions/ EnglishApp/Features/News/ EnglishApp/Features/Settings/ EnglishApp/Features/Tournaments/
# Also catching any straggling files just in case
git add .
git commit -m "feat: Add main tab navigation and feature stubs" || echo "No changes"
git push -u origin feature/home-tabs
