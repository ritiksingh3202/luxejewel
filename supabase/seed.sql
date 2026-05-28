-- Demo catalog: the eight original LuxeJewel products (images are bundled app assets).
insert into public.categories (name, sort_order) values
  ('Rings', 1), ('Necklaces', 2), ('Earrings', 3), ('Bracelets', 4)
on conflict (name) do update set sort_order = excluded.sort_order;

insert into public.products
  (slug, name, description, material, category_id, price_cents, rating, image_path, stock, sort_order)
select v.slug, v.name, v.description, v.material, c.id, v.price_cents, v.rating, v.image_path, v.stock, v.sort_order
from (values
  ('diamond-solitaire-ring', 'Diamond Solitaire Ring',
   'Exquisite 18K white gold solitaire ring featuring a brilliant 1-carat diamond. Timeless elegance for your special moments.',
   '18K White Gold', 'Rings', 249900, 4.8, 'assets/images/products/product_1.jpg', 12, 1),
  ('gold-pearl-necklace', 'Gold Pearl Necklace',
   'Luxurious 22K gold necklace adorned with natural pearls. A statement piece that exudes sophistication.',
   '22K Gold', 'Necklaces', 189900, 4.9, 'assets/images/products/product_2.jpg', 10, 2),
  ('emerald-drop-earrings', 'Emerald Drop Earrings',
   'Stunning emerald drop earrings set in platinum. Perfect blend of classic and contemporary design.',
   'Platinum', 'Earrings', 159900, 4.7, 'assets/images/products/product_3.jpg', 8, 3),
  ('tennis-bracelet', 'Tennis Bracelet',
   'Classic diamond tennis bracelet featuring 50 brilliant-cut diamonds in 18K white gold.',
   '18K White Gold', 'Bracelets', 329900, 5.0, 'assets/images/products/product_4.jpg', 5, 4),
  ('rose-gold-band-ring', 'Rose Gold Band Ring',
   'Delicate rose gold band with intricate detailing. Perfect for everyday elegance.',
   '14K Rose Gold', 'Rings', 89900, 4.6, 'assets/images/products/product_5.jpg', 20, 5),
  ('sapphire-pendant', 'Sapphire Pendant',
   'Royal blue sapphire pendant surrounded by diamonds, set in white gold.',
   '18K White Gold', 'Necklaces', 219900, 4.8, 'assets/images/products/product_6.jpg', 7, 6),
  ('diamond-hoop-earrings', 'Diamond Hoop Earrings',
   'Elegant diamond-studded hoop earrings in yellow gold. Timeless style for any occasion.',
   '18K Yellow Gold', 'Earrings', 129900, 4.9, 'assets/images/products/product_7.jpg', 15, 7),
  ('charm-bracelet', 'Charm Bracelet',
   'Sophisticated charm bracelet with symbolic gold charms. Tell your story in style.',
   '22K Gold', 'Bracelets', 179900, 4.7, 'assets/images/products/product_8.jpg', 9, 8)
) as v(slug, name, description, material, category, price_cents, rating, image_path, stock, sort_order)
join public.categories c on c.name = v.category
on conflict (slug) do update set
  name = excluded.name, description = excluded.description, material = excluded.material,
  category_id = excluded.category_id, price_cents = excluded.price_cents, rating = excluded.rating,
  image_path = excluded.image_path, stock = excluded.stock, sort_order = excluded.sort_order;
