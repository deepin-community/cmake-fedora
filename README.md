# Welcome to cmake-fedora

cmake-fedora consists a set of scripts and cmake modules that simply the
release software packages to RHEL and Fedora.

## Motivation
cmake-fedora is designed to automate most of the release tasks. It not only
save your time, but also keeping consistency of release information such as
version and release-notes in following places:

 * Release notes
 * ChangeLog
 * Tags
 * Spec ChangeLog
 * Fedpkg commit message
 * Bodhi notes

cmake-fedora also:

 * Check dependency among source archive and files to be packed.
 * Run rpmlint and koji scratch build before tag as sanity checks.
 * Easy upload to scp, sftp hosting services sites.
 * Translation targets like gettext and Zanata.
 * Create new project with proper CMakeLists.txt template and license files.
 * Avoid some pitfalls like all junk files are packed.

## Get cmake-fedora
### Git
```sh
git clone https://pagure.io/cmake-fedora.git
```

### Source Archive
Source archive download page:
https://releases.pagure.org/cmake-fedora

You can download the modules-only archive: cmake-fedora-<version>-modules-only.tar.gz

or the full archive that also include helper scripts and documentation: cmake-fedora-<version>.tar.gz

## Install
cmake-fedora can be installed as a Fedora/EPEL package using:
```sh
yum -y install cmake-fedora
```

Alternatively, you can install cmake-fedora for the package as:
* Git submodule:
```sh
git submodule init; git submodule update
ln -s cmake-fedora/Modules .
```
* Extracted Module-only source archives:
```sh
wget -P SOURCES https://releases.pagure.org/cmake-fedora/cmake-fedora-modules-only-latest.tar.gz
tar zxvf SOURCES/cmake-fedora-modules-only-latest.tar.gz")
```

## Work flow

### Starting a new project

#### 1. Edit CMakeLists.txt
cmake build instruction file. Edit it as you normally do with CMake projects.
It should contains note that project persistent information like project name, authors, licenses and project summary.

`cmake-fedora-newprj` can create CMakeLists.txt if it does not already exists, and helps to configure the basic
document like AUTHORS and COPYING.

#### 2. Edit RELEASE-NOTES.txt
This is file you put the version, change summary, !ChangeLog, Bugzilla Bug ID or anything about the upcoming versions/releases.

It looks like:
```
PRJ_VER=0.1.0
SUMMARY=Summary of this version

[Changes]

- Fixed RHBZ#XXXXXXX - bug 1 description
- fixed RHBZ#YYYYYYY - bug 2 description
- Fixes RHBZ#ZZZZZZZ - bug 3 description
- fixes RHBZ#WWWWWWW - bug 4 description
- other improvement
```

Note that something like `Fixes RHBZ#XXXXXXX` will make Bug XXXXXXXX
associates with this update in Bodhi, the Fedora update center.

The recognized syntax is:

 - Fixed RHBZ#(number)
 - fixed RHBZ#(number)
 - Fixes RHBZ#(number)
 - fixes RHBZ#(number)


#### 3. Develop as you normally would
#### 4. Translation (Optional)
Following are recommend steps to use gettext to translate your project:

 1. Create a sub directory 'po'
 2. Edit 'po/CmakeLists.txt'

       INCLUDE(ManageTranslation)
       INCLUDE(ManageZanata)

       SET(SOURCES_I18N ${CMAKE_SOURCE_DIR}/src/IBusChewingEngine.gob
           ${CMAKE_SOURCE_DIR}/src/IBusChewingEngine-input-events.c
           ${CMAKE_SOURCE_DIR}/src/IBusChewingEngine-def.c
           ${CMAKE_SOURCE_DIR}/src/main.c)

       MANAGE_GETTEXT(ALL SRCS ${SOURCES_I18N})

       MANAGE_ZANATA("https://translate.zanata.org/zanata/"
           YES
           VERSION "master"
           GENERATE_ZANATA_XML
       )

       ADD_DEPENDENCIES(pack_src_pre translations)

 3. `make pot_files` to generate .pot files
 4. (Optional) `make zanata_xml` for Zanata setting files.
 5. (Optional) `make zanata_push` to push the documents to Zanata for translation.
 6. Receive .po files from either translators. Or use `make zanata_pull`
 7. `make translations`

#### 5. Release the initial version
After commit the last change, just run `make release`

make release should:

 1. Create a source archive
 2. Create a source RPM and binary RPMs.
 3. Run rpmlint and koji scratch build to ensure it build in Koji
 4. Tag the source tree in given version
 5. Do the fedpkg import, commit, push and build for the fedora release you want.
 6. Do the bodhi update.

### Release a new version with cmake-fedora

When a release is ready, only need to update the `RELEASE_NOTES.txt` by fill in:

 * The new version
 * Summary of this release
 * Type of this release (default is bugfix)
 * What Bug this release actually fixed.
 * The detail list of changes under section [Changes]

No need to edit CMakeLists.txt again.

Start from Step 2 in previous section.

### Useful targets
 * `pot_files`: Generate pot files for translation.
 * `gmo_files`: Generate gmo files for translation.
 * `pack_src` : Create a source archive
 * `srpm:`    : Create a source RPM
 * `rpm`      : Create a source RPM and binary rpms
 * `rpmlint`  : Run rpmlint for all RPM files
 * `install_rpms` : Install all the binary rpms except the debuginfo
 * `koji_build_scratch` Run the koji scratch build for all targeted Fedora/EPEL release.
 * `upload`   : Upload files to hosting services
 * `tag`      : Tag the current source tree with the version specified in RELEASE_NOTES.txt
 * `fedpkg_build` : Run the fedpkg build for the specified Fedora/EPEL releases.
 * `release_fedora` : Release for Fedora and/or EPEL
 * `release`  : Run the release process. release_fedora will be invoked if Fedora build support is enabled.
 * `clean_pkg`: Remove all the source archive and RPM files.

### Submit Bug Reports or Feature Requests
Please [submit issues](https://bugzilla.redhat.com/enter_bug.cgi?format=guided&product=Fedora&component=cmake-fedora)

