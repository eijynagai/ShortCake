tag=1.0.0
docker tag rnakato/shortcake:latest rnakato/shortcake:$tag

for tag in $tag latest
do
    docker push rnakato/shortcake:$tag
done
