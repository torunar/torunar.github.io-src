build: init
	~/src/torunar.github.io-src/cider/cider.sh \
		-c="${HOME}/src/torunar.github.io-src/ru/config.sh" \
		-l="${HOME}/src/torunar.github.io-src/ru/localization.sh" \
		-i="${HOME}/src/torunar.github.io-src/ru/posts" \
		-o="${HOME}/src/torunar.github.io-src/www" \
		-t="brut" \
		-p=10 \
		-H="http://localhost:8888"
	~/src/torunar.github.io-src/cider/cider.sh \
		-c="${HOME}/src/torunar.github.io-src/en/config.sh" \
		-l="${HOME}/src/torunar.github.io-src/en/localization.sh" \
		-i="${HOME}/src/torunar.github.io-src/en/posts" \
		-o="${HOME}/src/torunar.github.io-src/www/en" \
		-t="brut" \
		-p=10 \
		-H="http://localhost:8888/en"

init:
	mkdir -p ~/src/torunar.github.io-src/www
	rm -rf ~/src/torunar.github.io-src/www/*
	git checkout ~/src/torunar.github.io-src/www

serve:
	php -S 0.0.0.0:8888 -t ~/src/torunar.github.io-src/www

update:
	git submodule update --remote
