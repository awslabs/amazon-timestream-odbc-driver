# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v2.1.0](https://github.com/awslabs/amazon-timestream-odbc-driver/releases/tag/v2.1.0) - 2024-07-10

### Added

- [OLE DB support](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).
- [Allow SQLGetData to retrieve variable-length data in parts](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).
- [Support SQL_ROWSET_SIZE statement attribute](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).
- [Add src/out to .gitignore](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).
- [Add CHANGELOG](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/16).

### Changed

- [Use GITHUB_OUTPUT instead of set-output command for Windows GitHub action workflow](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/9).
- [Update macOS workflow to use macos-12 runner](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).
- [Update configure-aws-credentials to v4 for all GitHub action workflows](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).
- [Use publish-unit-test-result macos@v2 for macOS GitHub action workflow](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).
- [Make run_cppcheck scripts use check-level exhaustive](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).
- [Use absolute paths in register_driver_unix.sh](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).

### Fixed

- [Fix error cause by cursor moving past the end of a result set](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).
- [Fix the character "-" being returned for null values](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).
- [Fix SQLFreeStmt not ignoring errors when freeing](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).
- [Fix various spelling errors in documentation and in comments](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).
- [Fix failing links in documentation](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/8).

### Removed

- [Remove requirement that array size be less than 1000](https://github.com/awslabs/amazon-timestream-odbc-driver/pull/15).

## [v2.0.0](https://github.com/awslabs/amazon-timestream-odbc-driver/releases/tag/v2.0.0) - 2023-08-08

### Added

- Initial release.
