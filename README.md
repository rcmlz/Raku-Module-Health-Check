|push to main|[![Linux Status](https://github.com/rcmlz/Raku-Module-Health-Check/actions/workflows/Linux.yml/badge.svg?event=push)](https://github.com/rcmlz/Raku-Module-Health-Check/actions)|[![MacOS Status](https://github.com/rcmlz/Raku-Module-Health-Check/actions/workflows/MacOS.yml/badge.svg?event=push)](https://github.com/rcmlz/Raku-Module-Health-Check/actions)|[![Windows Status](https://github.com/rcmlz/Raku-Module-Health-Check/actions/workflows/Windows.yml/badge.svg?event=push)](https://github.com/rcmlz/Raku-Module-Health-Check/actions) |
|---|---|---|---|
|scheduled run|[![Linux Status](https://github.com/rcmlz/Raku-Module-Health-Check/actions/workflows/Linux.yml/badge.svg?event=schedule)](https://github.com/rcmlz/Raku-Module-Health-Check/actions)|[![MacOS Status](https://github.com/rcmlz/Raku-Module-Health-Check/actions/workflows/MacOS.yml/badge.svg?event=schedule)](https://github.com/rcmlz/Raku-Module-Health-Check/actions)|[![Windows Status](https://github.com/rcmlz/Raku-Module-Health-Check/actions/workflows/Windows.yml/badge.svg?event=schedule)](https://github.com/rcmlz/Raku-Module-Health-Check/actions)|

NAME
====

Raku-Module-Health-Check - Module x Operating System - user installation tester.

SYNOPSIS
========

Triggered via github workflows - so we always start on a clean slate!

DESCRIPTION
===========

Automatically keeping an eye on modules you use - can the most recent version (still) be installed under Linux, MacOS and Windows?

Module can be installed ...

- Gold: all test activated, incl. AUTHOR, NETWORK, etc.
- Silver: dependency and module tests activated 
- Bronze: dependency test deactivated, module tests activated 
- Bogus: all tests deactivated
- Impossible: installation impossible

Put any number of .json files into the [resources/](https://github.com/rcmlz/Raku-Module-Health-Check/tree/main/resources) folder. The **set** of all detected [modules](https://raku.land/) is calculated and then processed by the workflow actions - triggered regularly.

Only the modules listed at the keys "depends", "build-depends" and "test-depends" are evaluated. Something like this:

```json
{
  "depends": [
    "App::Mi6:auth<zef:skaji>",
    "App::Prove6:auth<cpan:LEONT>",
  ],
  "build-depends": [
    "Test::Async:auth<zef:vrurg>"
  ],
  "test-depends": [
    "Benchmark:auth<zef:raku-community-modules>",
    "Test::META:auth<zef:jonathanstowe>:api<1.0>"
  ]
}
```

Any other keys in /resources/`*`.json files will be ignored, so you might just copy all your META6.json from all your projects into this folder - using different names for them, of course. To not get betrayed easily (trouble-makers publishing a bogus module with same name but higher version as the one you have installed) you want to fix at least the author and, if available, the API version of modules you use. 

ToDo: Merge Linux/Windows/Mac-result json files and send short/nice monthly status report (via E-Mail).

AUTHOR
======

rcmlz <rcmlz@github.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2023 rcmlz

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.