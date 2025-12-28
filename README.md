panel menumita



خروجی

cd /Users/milademoun/Public/project_flutter/NexaraCart/client_side/admin_panel/menumita

flutter build web --release

# ساخت tar.gz از محتوای build/web طوری که index.html "ریشه" باشد
tar --exclude menumita-web.tar.gz -czf menumita-web.tar.gz -C build/web .




flutter build web --release
tar -czf menumita-web.tar.gz -C build/web .
