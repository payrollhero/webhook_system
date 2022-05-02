# Change Log

## [v2.4.0](https://github.com/payrollhero/webhook_system/tree/v2.4.0) (2022-05-02)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v2.3.1...v2.4.0)

* Rails 7.0 Official support.
* Please read Upgrade notes, a migration is required to rename encrypt column to encrypted.

## [v2.3.1](https://github.com/payrollhero/webhook_system/tree/v2.3.1) (2022-04-27)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v2.3.0...v2.3.1)

* Rails 6.1 Official support.

## [v2.3.0](https://github.com/payrollhero/webhook_system/tree/v2.3.0) (2021-08-xx)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v2.2.0...v2.3.0)

* Add ability to launch inline jobs instead of making external HTTP calls to another service.

## [v2.2.0](https://github.com/payrollhero/webhook_system/tree/v2.2.0) (2019-11-07)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v2.1.6...v2.2.0)

* Syntatic sugar: simple dispatch call to also build the event object

## [v2.1.6](https://github.com/payrollhero/webhook_system/tree/v2.1.6) (2019-07-26)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v2.1.5...v2.1.6)

* add account info to error message

## [v2.1.5](https://github.com/payrollhero/webhook_system/tree/v2.1.5) (2019-07-24)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v2.1.4...v2.1.5)

* response body error message in exception

## [v2.1.4](https://github.com/payrollhero/webhook_system/tree/v2.1.4) (2019-05-10)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v2.1.3...v2.1.4)

* Make URL display in Exception message
* Make tests pass again
* Small typo fix by Heath Attig, thank you

## [v2.1.3](https://github.com/payrollhero/webhook_system/tree/v2.1.3) (2017-12-06)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v2.1.2...v2.1.3)

by Ron

## [v2.1.2](https://github.com/payrollhero/webhook_system/tree/v2.1.2) (2017-01-24)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v2.1.1...v2.1.2)

by Piotr

## [v2.1.1](https://github.com/payrollhero/webhook_system/tree/v2.1.1) (2016-12-20)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v2.1.0...v2.1.1)

by Piotr

## [v2.1.0](https://github.com/payrollhero/webhook_system/tree/v2.1.0) (2016-07-20)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v2.0.0...v2.1.0)

- Changing the main dispatch interface to call of a relation, enabling filtering of the subscriptions being considered [\#10](https://github.com/payrollhero/webhook_system/pull/10) ([piotrb](https://github.com/piotrb))

## [v2.0.0](https://github.com/payrollhero/webhook_system/tree/v2.0.0) (2016-07-19)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v1.0.4...v2.0.0)

- This adds support for plain text payloads, version bumps to 2.0 [\#9](https://github.com/payrollhero/webhook_system/pull/9) ([piotrb](https://github.com/piotrb))

## [v1.0.4](https://github.com/payrollhero/webhook_system/tree/v1.0.4) (2016-02-19)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v1.0.3...v1.0.4)

- Log any exception which occurs while we submit data to the webhook url. [\#8](https://github.com/payrollhero/webhook_system/pull/8) ([mykola-kyryk](https://github.com/mykola-kyryk))

## [v1.0.3](https://github.com/payrollhero/webhook_system/tree/v1.0.3) (2016-02-18)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v1.0.2...v1.0.3)

- Use updated 'faraday-encoding' gem. [\#7](https://github.com/payrollhero/webhook_system/pull/7) ([mykola-kyryk](https://github.com/mykola-kyryk))

## [v1.0.2](https://github.com/payrollhero/webhook_system/tree/v1.0.2) (2016-02-17)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v1.0.1...v1.0.2)

- Feature/add faraday encoding middleware and db transaction check [\#6](https://github.com/payrollhero/webhook_system/pull/6) ([mykola-kyryk](https://github.com/mykola-kyryk))

## [v1.0.1](https://github.com/payrollhero/webhook_system/tree/v1.0.1) (2016-02-16)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v1.0.0...v1.0.1)

- Add missing require for Faraday [\#5](https://github.com/payrollhero/webhook_system/pull/5) ([mykola-kyryk](https://github.com/mykola-kyryk))

## [v1.0.0](https://github.com/payrollhero/webhook_system/tree/v1.0.0) (2016-02-11)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v0.1.1...v1.0.0)

- Add event logging [\#4](https://github.com/payrollhero/webhook_system/pull/4) ([piotrb](https://github.com/piotrb))

## [v0.1.1](https://github.com/payrollhero/webhook_system/tree/v0.1.1) (2016-02-05)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v0.1.0...v0.1.1)

- Fixing hash based attribute definition and a few fixes [\#3](https://github.com/payrollhero/webhook_system/pull/3) ([piotrb](https://github.com/piotrb))

## [v0.1.0](https://github.com/payrollhero/webhook_system/tree/v0.1.0) (2016-02-05)
[Full Changelog](https://github.com/payrollhero/webhook_system/compare/v0.0.1...v0.1.0)

- Add easy topic mass assignment and url validation [\#2](https://github.com/payrollhero/webhook_system/pull/2) ([piotrb](https://github.com/piotrb))

## [v0.0.1](https://github.com/payrollhero/webhook_system/tree/v0.0.1) (2016-02-05)
- Initial implementation of the webhook system [\#1](https://github.com/payrollhero/webhook_system/pull/1) ([piotrb](https://github.com/piotrb))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
