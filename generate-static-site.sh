#!/bin/bash
branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

if [[ "$branch" != "main" ]]; then
    echo "Invalid Branch"
else
    git branch -D gh-pages
    git checkout -b gh-pages
    swift package --allow-writing-to-directory docs generate-documentation --target NetworkReachability --disable-indexing --transform-for-static-hosting --hosting-base-path docs --output-path docs
    tail -n +2 README.md > README-2.md && mv README-2.md README.md
    echo "reachability.tools" > CNAME
    echo "theme: jekyll-theme-modernist" > _config.yml
    git add .
    git commit -m 'Synchronize Hompage & Publish Documentation'
    git push -f -u origin gh-pages
    git checkout main
    git branch -D gh-pages
    rm -rf docs
    echo "Website Updated!"
fi
