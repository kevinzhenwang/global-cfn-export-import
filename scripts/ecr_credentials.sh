#!/usr/bin/env bash

mkdir -p ~/.aws

cat > ~/.aws/credentials << EOL
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}

[slave]
aws_access_key_id = ${SLAVE_AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${SLAVE_AWS_SECRET_ACCESS_KEY}
EOL