require 'mysql2'
client = Mysql2::Client.new(:host => "127.0.0.1", :username => "root", :password => "isucon", :database => "isuketch")

client.query('delete from img where room_id<=1000')
client.query('insert into img (room_id, img) select rooms.id as room_id, \'<?xml version="1.0" standalone="no"?><!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd"><svg xmlns="http://www.w3.org/2000/svg" version="1.1" baseProfile="full" width="1028" height="768" style="width:1028px;height:768px;background-color:white;" viewBox="0 0 1028 768">\' as img from rooms where id<=1000')
room_ids = client.query('SELECT id FROM rooms').to_a.map {|x|x['id']}

room_ids.each do |x|
  img = ''
  img = client.prepare('SELECT img from img where room_id = ?').execute(x).to_a[0]['img']
  puts x
  #puts img
  #puts x.inspect
  client.prepare('SELECT * from strokes WHERE room_id = ?').execute(x).to_a.each do |stroke|
    points = ''
    client.prepare('SELECT * from points WHERE stroke_id = ?').execute(stroke['id']).to_a.each do |p|
      points += '%f,%f ' % [p['x'].to_f, p['y'].to_f]
    end
    img += '<polyline id="%s" stroke="rgba(%d, %d, %d, %f)" stroke-width="%d" stroke-linecap="round" fill="none" points="%s"></polyline>' % [stroke['id'], stroke['red'], stroke['green'], stroke['blue'], stroke['alpha'], stroke['width'], points]
    #puts img
    #puts img
    client.prepare('UPDATE img SET img = ? WHERE room_id = ?').execute(img, x)
  end
end
