module UsersHelper
  
  def avatar_for(user, options = { size: 80 })
    size = options[:size]
    if user.avatar?
      image_tag(user.avatar.thumb.url, alt: user.username, class: options[:class], width: size, height: size)
    else
      # デフォルトの円形プレースホルダー
      content_tag(:div, user.username.first.upcase, 
        class: "#{options[:class]} d-flex align-items-center justify-content-center bg-secondary text-white",
        style: "width: #{size}px; height: #{size}px;")
    end
  end
end
  

