#!/bin/sh
DOCUMENT_ROOT=/var/www/sources

# Take site offline
echo "Taking site offline..."
touch $DOCUMENT_ROOT/maintenance.file

# Swap over the content
echo "Deploying content..."
mkdir -p $DOCUMENT_ROOT/Soundcloud
cp soundcloud.png $DOCUMENT_ROOT/Soundcloud
cp SoundcloudConfig.json $DOCUMENT_ROOT/Soundcloud
cp SoundcloudScript.js $DOCUMENT_ROOT/Soundcloud
sh sign.sh $DOCUMENT_ROOT/Soundcloud/SoundcloudScript.js $DOCUMENT_ROOT/Soundcloud/SoundcloudConfig.json

# Notify Cloudflare to wipe the CDN cache
echo "Purging Cloudflare cache for zone $CLOUDFLARE_ZONE_ID..."
curl -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/purge_cache" \
     -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"files":["https://plugins.grayjay.app/Soundcloud/soundcloud.png", "https://plugins.grayjay.app/Soundcloud/SoundcloudConfig.json", "https://plugins.grayjay.app/Soundcloud/SoundcloudScript.js"]}'

# Take site back online
echo "Bringing site back online..."
rm $DOCUMENT_ROOT/maintenance.file
