tag=1.5.1
docker tag rnakato/shortcake:latest rnakato/shortcake:$tag

for tag in $tag latest
do
    docker push rnakato/shortcake:$tag
done
