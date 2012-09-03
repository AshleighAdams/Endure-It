using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Windows.Forms;
using System.Drawing;
using System.Security.Cryptography;
namespace MapGen
{
    class Program
    {
        static void Main(string[] args)
        {
            RandomNumberGenerator rand = RandomNumberGenerator.Create();

            int scale = 1; // scale can be used to actually place the points further or closer together, resuliting in a smaller or larger map with the same number of triangles, but lower/heigher quality
            int size = 1024;
            int maxheight = 512 * scale; // change thes vals later, just tempory, scale so that when the map is scaled width and length, upwards is also scaled

            double[,] Pass1 = new double[size, size];

            for(int x = 0; x < size; x++)
                for (int y = 0; y < size; y++)
                {
                    int x1 = x - size / 2;
                    int y1 = y - size / 2;

                    double centerdist = Math.Sqrt((double)(x1 * x1 + y1 * y1)) / Math.Sqrt(size * size + size * size);
                    double coeficient = /*Math.Log(centerdist * 5, 10) * 0.35; */ Math.Pow(centerdist, 1.4);


                    coeficient += (Math.Cos((double)x / 33.33) + Math.Sin((double)y / 33.33) + 2) / 32 * 0.2; // 4 becase max cos/sin is 4, min is 0, 0.5 is influence

                    coeficient += (Math.Cos((double)(x) / 16) + Math.Sin((double)(y) / 16) + 1) / 40 * 0.2;

                    coeficient += (Math.Cos((double)(x + 100) * 0.005) + Math.Sin((double)(y + 100) * 0.005)) / 64 * 0.05 * 0.2;


                    coeficient = Math.Min(1, Math.Max(0, coeficient));
                    int maxheight_l = (int)(maxheight * coeficient);

                    byte[] randval = new byte[4]; // 4 bytes = int
                    rand.GetBytes(randval);
                    uint val = BitConverter.ToUInt32(randval, 0);

                    Pass1[x, y] = (double)val / (double)uint.MaxValue * maxheight_l;
                }

            new DisplayArray("Pass 1", ref Pass1, maxheight).ShowDialog();

            double[,] Pass2 = new double[size, size];

            int blursize = 8;

            for(int x = 0; x < size; x++)
                for (int y = 0; y < size; y++)
                {
                    double itt = 0;
                    double total = 0;
                    for (int xx = x - blursize; xx < x + blursize; xx++)
                        if (xx >= size || xx < 0)
                            continue;
                        else
                            for (int yy = y - blursize; yy < y + blursize; yy++)
                            {
                                if (yy >= size || yy < 0)
                                    continue;
                                itt++;
                                total += Pass1[xx, yy];
                            }

                    Pass2[x, y] = total / itt;
                }
            
            new DisplayArray("Pass 2", ref Pass2, maxheight).ShowDialog();
        }
    }
}
