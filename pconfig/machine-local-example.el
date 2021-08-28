; After pulling the config package:
; 1) Create an instance of machine-local.el. It will be gitignored by default
; 2) Copy the example commands below and fill out the appropriate values for the local machine-local


; TODO Some of the stuff in here isn't critical for emacs to function. We should be able to detect
; in .emacs if we have values like the rust-mode path in here and only init it when thats true.
; So this file should probably only export values that .emacs picks up on.

; Set the default working path for this machine, e.g. where you want find-file to start at by default
(setq default-directory <DEFAULT_WORKING_PATH> )

; The load path for the rust-mode package: https://github.com/rust-lang/rust-mode
(add-to-list 'load-path <RUST_MODE_PATH>)

; The location of the voidtools-provided cli for everything: https://www.voidtools.com/support/everything/command_line_interface/
(setq everything-cmd "<ES_EXE_PATH>)