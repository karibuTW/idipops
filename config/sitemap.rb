# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://idipops.com"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
  add "/uneo", :priority => 0.9, :changefreq => 'yearly'
  add "/cgv", :priority => 0.1, :changefreq => 'yearly'
  add "/comment-ca-marche-particuliers", :priority => 0.6, :changefreq => 'yearly'
  add "/comment-ca-marche-champions", :priority => 0.6, :changefreq => 'yearly'
  add "/bons-plans", :priority => 0.7, :changefreq => 'weekly'

  User.pro.active.find_each do |pro|
    add "/pro/#{pro.pretty_name}", :priority => 0.8, :changefreq => 'monthly'
  end
  ClassifiedAd.with_published_state.select('classified_ads.*').find_each do |classified_ad|
    add "/annonce-publique/#{classified_ad.id}", :priority => 0.9, :changefreq => 'weekly'
  end
  Deal.active.find_each do |deal|
    add "/bon-plan/#{deal.id}", :priority => 0.9, :changefreq => 'weekly'
  end
  Post.with_published_state.find_each do |post|
    add "/post/#{post.slug}", :priority => 1, :changefreq => 'yearly'
  end
end
