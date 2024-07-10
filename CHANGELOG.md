# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v2.1.0](https://github.com/awslabs/amazon-timestream-odbc-driver/releases/tag/v2.1.0) - 2024-07-10

### Added

- OLE DB support (#11).
- Allow SQLGetData to retrieve variable-length data in parts.
- Support SQL_ROWSET_SIZE statement attribute.
- Add src/out to .gitignore.
- Add CHANGELOG.

### Changed

- Use GITHUB_OUTPUT instead of set-output command for Windows GitHub action workflow.
- Updated macOS workflow to use macos-12 runner.
- Update configure-aws-credentials to v4 for all GitHub action workflows.
- Use publish-unit-test-result macos@v2 for macOS GitHub action workflow.
- Make run_cppcheck scripts use check-level exhaustive.
- Use absolute paths in register_driver_unix.sh.

### Fixed

- Fix error cause by cursor moving past the end of a result set (#10).
- Fix the character "-" being returned for null values (#12).
- Fixed SQLFreeStmt not ignoring errors when freeing.
- Fixed various spelling errors in documentation and in comments.

### Removed

- Remove requirement that array size be less than 1000.

## [v2.0.0](https://github.com/awslabs/amazon-timestream-odbc-driver/releases/tag/v2.0.0) - 2023-08-08

### Added

- Initial release.
