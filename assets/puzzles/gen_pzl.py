#!/usr/bin/env python3
from PIL import Image
import random

def generate_random_puzzle(width=20, height=20, output_filename="puzzle0001.png"):
    # Create a new image with mode "RGB". The background is set to white.
    img = Image.new("RGB", (width, height), "white")
    
    # Fill each pixel randomly with black (filled) or white (empty).
    for y in range(height):
        for x in range(width):
            if random.random() < 0.5:
                color = (0, 0, 0)   # black for filled
            else:
                color = (255, 255, 255)  # white for empty
            img.putpixel((x, y), color)
    
    # Save the image as a PNG file.
    img.save(output_filename)
    print(f"Random puzzle image generated and saved as {output_filename}")

if __name__ == '__main__':
    generate_random_puzzle()
