#!/bin/bash
branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')

run_docc () {
    swift package --allow-writing-to-directory docs generate-documentation --target NetworkReachability --disable-indexing --transform-for-static-hosting --hosting-base-path docs --output-path docs --include-extended-types
}

create_branches () {
    git branch -D gh-pages
    git checkout -b gh-pages
}

fix_readme () {
    tail -n +2 README.md > README-2.md && mv README-2.md README.md
}

configure_site () {
    echo "reachability.tools" > CNAME
    echo "theme: jekyll-theme-modernist" > _config.yml
}

commit_and_publish () {
    git add .
    git commit -m 'Synchronize Hompage & Publish Documentation'
    git push -f -u origin gh-pages
}

clean_up () {
    git checkout main
    git branch -D gh-pages
    rm -rf docs
}

generate_documentation () {
    create_branches
    run_docc
    fix_readme
    configure_site
    commit_and_publish
    clean_up
}

if [[ "$branch" != "main" ]]; then
    echo "Invalid Branch"
elif [[ -n $(git status -s) ]]; then
    echo "Uncommited Changes"
else
    generate_documentation
    echo "Website Updated!"
fi
