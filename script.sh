#!/bin/bash

# Function to print formatted messages
print_message() {
    echo -e "\n\e[1m$1\e[0m"
}

# Directories
directories=("/public" "/adm" "/ven" "/sec")

# Groups
groups=("GRP_ADM" "GRP_VEN" "GRP_SEC")

# Users and their respective groups
declare -A users=(
    ["carlos"]="GRP_ADM"
    ["maria"]="GRP_ADM"
    ["joao"]="GRP_ADM"
    ["debora"]="GRP_VEN"
    ["sebastiana"]="GRP_VEN"
    ["roberto"]="GRP_VEN"
    ["josefina"]="GRP_SEC"
    ["amanda"]="GRP_SEC"
    ["rogerio"]="GRP_SEC"
)

# Users passwords
declare -A user_password=(
    ["carlos"]="carlos123"
    ["maria"]="maria123"
    ["joao"]="joao123"
    ["debora"]="debora123"
    ["sebastiana"]="sebastiana123"
    ["roberto"]="roberto123"
    ["josefina"]="josefina123"
    ["amanda"]="amanda123"
    ["rogerio"]="rogerio123"

)

# Check if the script is being run by root
if [[ $EUID -ne 0 ]]; then
    SUDO=sudo
else
    SUDO=""
fi

# Step 1: Create directories and set permissions and ownership
print_message "Step 1: Creating directories and setting permissions and ownership"
for dir in "${directories[@]}"; do
    $SUDO mkdir -p "$dir"
    $SUDO chown root:root "$dir"
    echo "Created directory: $dir"
done

# Step 2: Create groups
print_message "Step 2: Creating groups"
for group in "${groups[@]}"; do
    if ! getent group "$group" >/dev/null; then
        $SUDO groupadd "$group"
        echo "Created group: $group"
    else
        echo "Group $group already exists"
    fi
done

# Step 3: Create users and assign to groups
print_message "Step 3: Creating users and assigning to groups"
for user in "${!users[@]}"; do
    if ! id "$user" >/dev/null 2>&1; then
        encrypted_password=$(openssl passwd -6 "${user_password[$user]}")
        $SUDO useradd -G "${users[$user]}" -s /bin/bash -m -p "$encrypted_password" "$user"
        echo "Created user: $user (Group: ${users[$user]})"
    else
        echo "User $user already exists"
    fi
done

# Step 4: Set permissions and assign group permissions
print_message "Step 4: Setting permissions and assigning group permissions"
for group in "${groups[@]}"; do
    dir_name="/${group#GRP_}"
    dir_name="${dir_name,,}"
    $SUDO chmod 770 "$dir_name"
    $SUDO chown root:"$group" "$dir_name"
    echo "Set permissions for $dir_name (Group: $group)"
done

# Step 5: Set global permissions for /public
$SUDO chmod 777 /public
echo "Set global permissions for /public (777)"

print_message "Script execution completed."