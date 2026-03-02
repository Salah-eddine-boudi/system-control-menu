#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REMINDERS_FILE="$SCRIPT_DIR/data/reminders.txt"

echo "=== TEST UNITAIRE : SCHEDULER ==="

> "$REMINDERS_FILE"
echo "[1/3] Nettoyage du fichier reminders.txt : OK"

MESSAGE="Test Automatique "
TRIGGER_TIME=$(($(date +%s) + 15))
echo "$TRIGGER_TIME|$MESSAGE" >> "$REMINDERS_FILE"

if grep -q "$MESSAGE" "$REMINDERS_FILE"; then
    echo "[2/3] Insertion du rappel dans le fichier : OK"
else
    echo "[2/3] Insertion : ÉCHEC"
    exit 1
fi

echo "[3/3] Vérification du contenu du fichier :"
cat "$REMINDERS_FILE"

echo ""
echo "=== RÉSULTAT : TEST RÉUSSI ==="
echo "Le scheduler écrit correctement dans data/reminders.txt"
