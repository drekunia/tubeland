import os

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # 1. Duplicate VolumeHBox for Music and SFX
    volume_hbox_block = """[node name="VolumeHBox" type="HBoxContainer" parent="SettingsVBox"]
layout_mode = 2

[node name="Label" type="Label" parent="SettingsVBox/VolumeHBox"]
layout_mode = 2
size_flags_horizontal = 3
text = "Master Volume"

[node name="VolumeSlider" type="HSlider" parent="SettingsVBox/VolumeHBox"]
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 4
max_value = 10.0
step = 1.0
value = 10.0"""
    
    music_hbox_block = """[node name="MusicHBox" type="HBoxContainer" parent="SettingsVBox"]
layout_mode = 2

[node name="Label" type="Label" parent="SettingsVBox/MusicHBox"]
layout_mode = 2
size_flags_horizontal = 3
text = "Music Volume"

[node name="MusicSlider" type="HSlider" parent="SettingsVBox/MusicHBox"]
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 4
max_value = 10.0
step = 1.0
value = 10.0"""

    sfx_hbox_block = """[node name="SFXHBox" type="HBoxContainer" parent="SettingsVBox"]
layout_mode = 2

[node name="Label" type="Label" parent="SettingsVBox/SFXHBox"]
layout_mode = 2
size_flags_horizontal = 3
text = "SFX Volume"

[node name="SFXSlider" type="HSlider" parent="SettingsVBox/SFXHBox"]
layout_mode = 2
size_flags_horizontal = 3
size_flags_vertical = 4
max_value = 10.0
step = 1.0
value = 10.0"""
    
    replacement = volume_hbox_block + "\n\n" + music_hbox_block + "\n\n" + sfx_hbox_block
    if volume_hbox_block in content:
        content = content.replace(volume_hbox_block, replacement)
    else:
        print(f"VolumeHBox block not found exactly in {filepath}")
        
    # 2. Duplicate connections
    volume_conn = '[connection signal="value_changed" from="SettingsVBox/VolumeHBox/VolumeSlider" to="." method="_on_volume_slider_value_changed"]'
    music_conn = '[connection signal="value_changed" from="SettingsVBox/MusicHBox/MusicSlider" to="." method="_on_music_slider_value_changed"]'
    sfx_conn = '[connection signal="value_changed" from="SettingsVBox/SFXHBox/SFXSlider" to="." method="_on_sfx_slider_value_changed"]'
    
    conn_replacement = volume_conn + "\n" + music_conn + "\n" + sfx_conn
    
    if volume_conn in content:
        content = content.replace(volume_conn, conn_replacement)
    else:
        print(f"Connection not found in {filepath}")

    with open(filepath, 'w') as f:
        f.write(content)
        
process_file(r'D:\Files\Projects\tubeland\scenes\system\main_menu.tscn')
process_file(r'D:\Files\Projects\tubeland\scenes\system\pause_menu.tscn')
print("Done modifying tscn files")
