# Changelog

All notable changes to this project will be documented in this file.

This project follows [Semantic Versioning](https://semver.org/).

---

## [1.0.0] - 2025-09-18

### Added

- Initial release of **smart_response_builder** 🎉
- `ResponseBuilder<T>` widget for managing:
  - API loading, success, error, empty, and offline states
  - Pagination support (`isLoadingMore`, `hasMore`, `paginationError`)
- Built-in offline widget with retry support
- Fully customizable builders for all states
- Example app demonstrating:
  - Simple usage with static data
  - Advanced usage with infinite scroll + offline detection
- Comprehensive documentation and README

### Notes

- Compatible with Flutter 3.x and Dart 3.x
- Designed to work with any state management solution (Provider, Riverpod, GetX, Bloc, etc.)
