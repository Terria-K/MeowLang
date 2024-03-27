using System;
using System.Runtime.ExceptionServices;

namespace MeowLang;

public class Word 
{
    private char[] words;
    private int length;
    public Word(string word) 
    {
        length = word.Length;
        words = new char[word.Length];
        for (int i = 0; i < words.Length; i++) 
        {
            words[i] = word[i];
        }
    }

    public bool IsCorrect(string line, ref int current, int lineNum) 
    {
        try 
        {
            for (int i = 1; i < length; i++) 
            {
                var ch = (char)line[current + i];

                if (ch != words[i]) 
                {
                    Console.WriteLine($"Compiler error at Ln {lineNum + 1} Col {current + 2}");
                    return false;
                }
            }
            current += length - 1;
        }
        catch 
        {
            Console.WriteLine("Reach end of line while compiling!");
            return false;
        }

        return true;
    }
}