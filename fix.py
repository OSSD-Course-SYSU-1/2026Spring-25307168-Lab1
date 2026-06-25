import pathlib
p = pathlib.Path(r'e:\lezihuawei\target\entry\src\main\ets\pages\GamePage.ets')
c = p.read_text(encoding='utf-8')

# Replace getSizeValue calls with hardcoded ternary for count buttons
old = """.width(getSizeValue(GP.countButtonSize, this.isSmallScreen))
                  .height(getSizeValue(GP.countButtonSize, this.isSmallScreen))
                  .fontSize(getSizeValue(GP.countButtonFontSize, this.isSmallScreen))"""

new = """.width(this.isSmallScreen ? 36 : 48)
                  .height(this.isSmallScreen ? 36 : 48)
                  .fontSize(this.isSmallScreen ? 16 : 20)"""

c = c.replace(old, new)

# Also replace borderRadius
old2 = ".borderRadius(getSizeValue(GP.countButtonBorderRadius, this.isSmallScreen))"
new2 = ".borderRadius(this.isSmallScreen ? 18 : 24)"
c = c.replace(old2, new2)

p.write_text(c, encoding='utf-8')
print('Done')
