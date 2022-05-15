#!/bin/bash
branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

if [[ "$branch" != "main" ]]; then
    echo "Invalid Branch"
else
    git branch -D gh-pages
    git checkout -b gh-pages
    swift package --allow-writing-to-directory docs generate-documentation --target Reachability --disable-indexing --transform-for-static-hosting --hosting-base-path docs --output-path docs
    echo "reachability-swift.dev" > CNAME
    git add .
    git commit -m 'Synchronize Hompage & Publish Documentation'
    git push -f -u origin gh-pages
    git checkout main
    echo "Website Updated!"
fi
