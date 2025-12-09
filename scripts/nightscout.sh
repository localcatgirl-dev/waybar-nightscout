#!/usr/bin/env bash

# Nightscout URL
# INSERT YOUR NIGHTSCOUT URL
NS_URL="______________"

PARAMS="?count=1"

data=$(curl -sf "$NS_URL/api/v1/entries.json$PARAMS") || {
  printf '{"text":"NS ?","class":["nightscout","range-error"]}\n'
  exit 0
}

sgv=$(echo "$data" | jq '.[0].sgv')
direction=$(echo "$data" | jq -r '.[0].direction')

#
# mg/dL to mmo/l (1 mmol/L ≈ 18 mg/dL)
mmol=$(awk "BEGIN { printf \"%.1f\", $sgv/18 }")

# Arrows
case "$direction" in
  DoubleUp)      arrow="⬆⬆" ;;
  SingleUp)      arrow="⬆" ;;
  FortyFiveUp)   arrow="⬈" ;;
  Flat)          arrow="➡" ;;
  FortyFiveDown) arrow="⬊" ;;
  SingleDown)    arrow="⬇" ;;
  DoubleDown)    arrow="⬇⬇" ;;
  *)             arrow=""  ;;
esac

# Color codes
# Change values by your preference
range_class=$(awk -v v="$mmol" 'BEGIN{
  if (v <= 4.3)              print "low";
  else if (v >= 10 && v <= 12.9)   print "10_12";
  else if (v >= 13 && v <= 15.9) print "13_159";
  else if (v >= 16)              print "16plus";
  else                           print "normal";
}')

text="${mmol}${arrow}"

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/nightscout_last_range"

notify_for_range() {
  local range="$1"
  local mmol_val="$2"
  local arrow_val="$3"

  local urgency="critical"
  local summary=""
  local body=""

  # You can customize your notification text, only tested on swaync
  case "$range" in
    low)
      urgency="critical"
      summary="💀🩸⬇LOW BLOOD SUGAR!⬇🩸💀"
      body="Value: ${mmol_val}${arrow_val} mmol/L"
      ;;
    10_12)
      urgency="critical"
      summary="🩸⬆HIGH BLOOD SUGAR!⬆🩸"
      body="Value: ${mmol_val}${arrow_val} mmol/L"
      ;;
    13_159)
      urgency="critical"
      summary="🩸⬆⬆HIGHER BLOOD SUGAR!⬆⬆🩸"
      body="Value: ${mmol_val}${arrow_val} mmol/L"
      ;;
    16plus)
      urgency="critical"
      summary="🩸⬆⬆⬆CRITIAL HIGH BLOOD SUGAR!⬆⬆⬆🩸"
      body="Value: ${mmol_val}${arrow_val} mmol/L"
      ;;
    *)
      return 0
      ;;
  esac

  notify-send -u "$urgency" "$summary" "$body"
}

last_range=""
if [ -f "$STATE_FILE" ]; then
  last_range=$(cat "$STATE_FILE")
fi

if [ "$range_class" != "$last_range" ]; then
  notify_for_range "$range_class" "$mmol" "$arrow"
  printf '%s\n' "$range_class" > "$STATE_FILE"
fi


# output for JSON (Waybar module)
printf '{"text":"%s","class":["nightscout","range-%s"]}\n' "$text" "$range_class"
