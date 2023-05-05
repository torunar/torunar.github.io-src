build: init
	~/src/cider/cider.sh \
		-c="${HOME}/src/torunar.ml/cider_config.sh" \
		-l="${HOME}/src/torunar.ml/cider_localization.sh" \
		-i="${HOME}/src/torunar.ml/posts" \
		-o="${HOME}/src/torunar.ml/www" \
		-t="brut" \
		-p=10 \
		-H="http://localhost:8888"

init: clean
	mkdir -p ${HOME}/src/torunar.ml/www

clean:
	rm -rf ${HOME}/src/torunar.ml/www

serve:
	php -S 0.0.0.0:8888 -t ~/src/torunar.ml/www
