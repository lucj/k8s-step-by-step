for m in vote-ui vote worker result result-ui tools; do
  tag=$(crane ls voting/$m | tail -n 1)

  echo "$(echo $m | tr -d '-'):"
  echo "  tag: $tag"
done