build: init
	~/src/cider/cider.sh \
		-c="${HOME}/src/torunar.github.io-src/cider_config.sh" \
		-l="${HOME}/src/torunar.github.io-src/cider_localization.sh" \
		-i="${HOME}/src/torunar.github.io-src/posts" \
		-o="${HOME}/src/torunar.github.io-src/www" \
		-t="brut" \
		-p=10 \
		-H="http://localhost:8888"

init:
	mkdir -p ~/src/torunar.github.io-src/www
	rm -rf ~/src/torunar.github.io-src/www/*
	git checkout ~/src/torunar.github.io-src/www

serve:
	php -S 0.0.0.0:8888 -t ~/src/torunar.github.io-src/www

update:
	git submodule update --remote
