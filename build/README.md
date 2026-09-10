# NOTE

The deb package creation is still under development

Directories:

```
                                                                              set in       set in        in
                                                                              common.sh    build.conf    build.sh
├── build.conf          # configuration for package build
├── build.log           # build log
├── build-debug.log     # build debug log
├── build.sh            # build script
├── common.sh           # common definitions for build and install
├── compareVersions.sh  # to test version up- and downgrade recognition
│
├── deb                 # directory which receives the built deb packages     $DEB_TGT                           <--.
│   │                                                                                                               |
│   ├── raspibackup_0.7.4-m-972.deb                                                                                 |
│   ├── raspibackup_0.7.4-m-972.deb.sig                                                                             |
│   ├── raspibackup.deb -> raspibackup_0.7.4-m-972.deb                                                              |
│   └── raspibackup.deb.sig -> raspibackup_0.7.4-m-972.deb.sig                                                      |
│                                                                                                                   |
├── gpg.conf            # gpg key id used to sign the packages                                                      |
├── install.log         # installation log                                                                          |
├── install.sh          # install packages                                                                          |
│                                                                                                                   |
├── package                                                                   $PACKAGE                              |
│   │                                                                                                               |
│   ├── DEBIAN          # DEBIAN package source                                                             --.     |
│   │   ├── conffiles   # definition of config files                                                          |     |
│   │   ├── control     # package control file                                                                v     |
│   │   ├── copyright                                                                                         |     |
│   │   ├── postinst    # script executed after package installation                                          |     |
│   │   └── postrm      # script executed after apt remove  (not existing yet)                                |     ^
│   │                                                                                                         |     |
│   └── src             # deb package build directory                         $TGT                         <--´   --´
│       ├── DEBIAN
│       │    └── ...
│       └── usr
│           └── local
│               ├── bin                                                                    $DIR_BIN        <--.
│               ├── etc                                                                    $DIR_ETC        <--|
│               ├── lib                                                                    $DIR_LIB        <--|
│               └── share                                                                  $DIR_SHARE      <--|
│                                                                                                             |
├── raspiBackupInstall.sh   # draft public installation script, uses the deb and gpg key from github          |
└── README.md               # the file you are reading just now                                               |
                                                                                                              ^
                                                                                                              |
/tmp/raspiBackup_gitsrc4deb.XXXXXX                                                                         $GITSRC
```

The `.deb` and `.deb.sig` files are pushed to GitHub then, perhaps with an appropriate tag. Or as "release"??

The user can download and install them manually or with the help of `raspiBackupInstall.sh` then.

