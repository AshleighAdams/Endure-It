using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Windows.Forms;
using System.Drawing;

using System.IO;

namespace MapGen
{
	class Program
	{
		static void ParseLine(string input, out double x, out double y, out double height)
		{
			int i = 0;
			x = y = 0;
			height = 0;

			string[] split = input.Split(" ".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);

			y = double.Parse(split[0]);
			x = double.Parse(split[1]);
			height = double.Parse(split[2]);
		}

		static void Main(string[] args)
		{
			int curx = 0;
			int cury = 0;
			double[,] input = new double[2048, 2048];

			using (StreamReader r = new StreamReader("C:\\Users\\C0BRA\\Desktop\\Cherno\\chernarus_8WVR.xyz"))
			{
				while (!r.EndOfStream)
				{
					if (cury == 2048)
					{
						cury = 0;
						curx++;
						Console.WriteLine(curx);
					}
					double x, y, e;
					ParseLine(r.ReadLine(), out x, out y, out e);
					input[2047 - curx, cury] = e;
					cury++;
				}
			}


			new DisplayArray("Pass", ref input).ShowDialog();
		}
	}
}
