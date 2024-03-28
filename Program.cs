using System;
using System.IO;
using System.Runtime.InteropServices;
using MeowLang;
unsafe {

if (args.Length == 0) 
{
    Console.WriteLine("Please specify an input file.");
    return;
}

string input = args[0];

using var fs = File.OpenText(input);

string texts = fs.ReadToEnd();

byte *blocks = (byte*)NativeMemory.AllocZeroed(255);

var meow = new Word("meow");
var woem = new Word("woem");
var purr = new Word("purr");
var rrup = new Word("rrup");
var feed = new Word("feed");

int lineNum = 0;
int currentBlock = 0;
bool commented = false;

// Loops
bool isLooping = false;
int currentLine = 0;
int currentColumn = 0;

string[] lines = texts.Split(Environment.NewLine);
for (int i = 0; i < lines.Length; i++)
{
    string line = lines[i];
    for (int r = 0; r < line.Length; r++) 
    {
        char c = (char)line[r];

        switch (c) 
        {
        case ':' when !commented:
            if (currentBlock == 254)
                currentBlock = 0;
            else
                currentBlock++;
            break;
        case '3' when !commented:
            if (currentBlock == 0)
                currentBlock = 254;
            else
                currentBlock--;
            break;
        case 'm' when !commented:
            if (meow.IsCorrect(line, ref r, lineNum)) 
            {
                blocks[currentBlock]++;
            }
            break;
        case 'w' when !commented:
            if (woem.IsCorrect(line, ref r, lineNum)) 
            {
                blocks[currentBlock]--;
            }
            break;
        case 'p' when !commented:
            if (purr.IsCorrect(line, ref r, lineNum)) 
            {
                currentColumn = r + 1;
                currentLine = i;
                isLooping = true;
            }
            break;
        case 'f' when !commented:
            if (feed.IsCorrect(line, ref r, lineNum)) 
            {
                Console.Write((char)blocks[currentBlock]);
            }
            break;
        case '(' when !commented:
            commented = true;
            break;
        case ')':
            commented = false;
            break;
        case 'r' when !commented:
            if (rrup.IsCorrect(line, ref r, lineNum)) 
            {
                if (!isLooping) 
                {
                    Console.WriteLine($"Loop is not even started yet! Ln {lineNum + 1} Col {r + 1}");
                    return;
                }
                if (blocks[currentBlock] == 0) 
                {
                    isLooping = false;
                }
                else 
                {
                    i = currentLine;
                    r = currentColumn - 1;
                }
            }
            break;
        }
    }
    lineNum++;
}

NativeMemory.Free(blocks);
}