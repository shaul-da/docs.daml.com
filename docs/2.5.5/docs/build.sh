#!/usr/bin/env bash
# Copyright (c) 2022 Digital Asset (Switzerland) GmbH and/or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

set -eou pipefail

DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$DIR"

RELEASE_TAG=$(jq -r '.daml' ../LATEST)
CANTON_RELEASE_TAG=$(jq -r '.canton' ../LATEST)
DAML_FINANCE_RELEASE_TAG=$(jq -r '.daml_finance' ../LATEST)
SOURCE_DIR=workdir/downloads
TARGET_DIR=workdir/target
rm -rf $TARGET_DIR
mkdir -p $TARGET_DIR

prefix=$(jq -r '.prefix' ../LATEST)

echo "Building docs for $prefix (daml: $RELEASE_TAG, canton: $CANTON_RELEASE_TAG, daml-finance: $DAML_FINANCE_RELEASE_TAG)"

BUILD_DIR=workdir/build
rm -rf $BUILD_DIR

mkdir -p $BUILD_DIR/source $BUILD_DIR/sphinx-target

./setup-sphinx-source-tree.sh

declare -A sphinx_targets=( [html]=html [pdf]=latex )
declare -A sphinx_flags=( [html]=-W [pdf]=-W )

for name in "${!sphinx_targets[@]}"; do
    target=${sphinx_targets[$name]}
    sphinx-build ${sphinx_flags[$name]} --color -b $target -c $BUILD_DIR/source/configs/$name $BUILD_DIR/source/source $BUILD_DIR/sphinx-target/$name
done

# Build PDF docs
tar xf $SOURCE_DIR/pdf-fonts-$RELEASE_TAG.tar.gz -C $BUILD_DIR/sphinx-target/pdf
cd $BUILD_DIR/sphinx-target/pdf
lualatex -halt-on-error -interaction=batchmode --shell-escape *.tex
lualatex -halt-on-error -interaction=batchmode --shell-escape *.tex
cd -
mv $BUILD_DIR/sphinx-target/pdf/DigitalAssetSDK.pdf $TARGET_DIR/pdf-docs-$RELEASE_TAG.pdf

# Merge HTML docs
tar xf $SOURCE_DIR/non-sphinx-html-docs-$RELEASE_TAG.tar.gz -C $BUILD_DIR/sphinx-target/html --strip-components=1
DATE=$(date --rfc-3339=date)
cp $TARGET_DIR/pdf-docs-$RELEASE_TAG.pdf $BUILD_DIR/sphinx-target/html/_downloads/DamlEnterprise${prefix}.pdf
mkdir $BUILD_DIR/sphinx-target/html/canton/scaladoc
tar xf $SOURCE_DIR/canton-scaladoc-$CANTON_RELEASE_TAG.tar.gz  -C $BUILD_DIR/sphinx-target/html/canton/scaladoc  --strip-components=1
rm -r $BUILD_DIR/sphinx-target/html/.buildinfo $BUILD_DIR/sphinx-target/html/.doctrees $BUILD_DIR/sphinx-target/html/objects.inv
(
    cd $BUILD_DIR/sphinx-target/html
    SMHEAD="<?xml version='1.0' encoding='UTF-8'?><urlset xmlns='http://www.sitemaps.org/schemas/sitemap/0.9' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd'>"
    SMITEM="<url><loc>%LOC%</loc><lastmod>${DATE}</lastmod><changefreq>daily</changefreq><priority>0.8</priority></url>"
    SMFOOT="</urlset>"
    echo $SMHEAD > sitemap.xml
    while read item; do
        echo $SMITEM | sed -e "s,%LOC%,${item}," >> sitemap.xml
    done < <(find . -name '*.html' | sort | sed -e 's,^\./,https://docs.daml.com/,')
    echo $SMFOOT >> sitemap.xml
)
tar cfz $TARGET_DIR/html-docs-$RELEASE_TAG.tar.gz  -C $BUILD_DIR/sphinx-target html
