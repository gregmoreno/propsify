GravatarHelper::SIZES = {
  :small  => 45,
  :medium => 65,
  :big    => 90,
}

GravatarHelper::SIZES[:default] = GravatarHelper::SIZES[:small]
GravatarHelper::SIZES.default = GravatarHelper::SIZES[:default]

GravatarHelper::DEFAULT_OPTIONS.update(
  :default => 'http://' + [ $BASE_HOST, $BASE_PORT ].reject(&:blank?).join(':') + '/images/icons/default_face.gif',
  :size => GravatarHelper::SIZES[:default]
)
