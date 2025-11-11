#!/bin/bash

# Make all scripts executable

echo "Making all scripts executable..."

chmod +x 00-set-variables.sh
chmod +x 01-create-resource-group.sh
chmod +x 02-create-acr.sh
chmod +x 03-create-postgres.sh
chmod +x 04-build-push-images.sh
chmod +x 05-deploy-scheduler.sh
chmod +x 06-deploy-webserver.sh
chmod +x 07-setup-permissions.sh
chmod +x 99-cleanup.sh
chmod +x deploy-all.sh

echo "✅ All scripts are now executable"
echo ""
echo "To run them in sequence:"
echo "  1. source 00-set-variables.sh"
echo "  2. ./01-create-resource-group.sh"
echo "  3. ./02-create-acr.sh"
echo "  4. ./03-create-postgres.sh"
echo "  5. ./04-build-push-images.sh"
echo "  6. ./05-deploy-scheduler.sh"
echo "  7. ./06-deploy-webserver.sh"
echo "  8. ./07-setup-permissions.sh"
echo ""
echo "Or run everything at once:"
echo "  ./deploy-all.sh"
