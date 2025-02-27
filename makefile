gen_code:
	# generate the generated code
	dart run build_runner build --delete-conflicting-outputs
	flutter pub get

preview_fix_linst:
	# preview proposed changes
	dart fix --dry-run

fix_lints:
	# apply proposed changes
	 dart fix --apply

format_code:
	# format the code
	dart format . -l 120

gen_splash:
	# generate splash screen
	dart run flutter_native_splash:create --path=./yaml/splash.yaml

gen_icon_launcher:
	# generate app launcher icon
	dart run flutter_launcher_icons -f ./yaml/icon_launcher.yaml