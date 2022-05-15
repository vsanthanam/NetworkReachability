git branch -D gh-pages
git checkout -b gh-pages
swift package --allow-writing-to-directory docs generate-documentation --target Reachability --disable-indexing --transform-for-static-hosting --hosting-base-path Reachability/docs --output-path docs
git add .
git commit -m 'Publish Documentatin'
git push -f -u origin gh-pages