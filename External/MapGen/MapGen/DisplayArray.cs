using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

using System.Drawing;

namespace MapGen
{
	public partial class DisplayArray : Form
	{
		public DisplayArray(string title, ref double[,] values)
		{
			InitializeComponent();
			this.Text = title;

			double maxheight = 0;
			double minheight = 0;

			foreach (double x in values)
			{
				if (x > maxheight)
					maxheight = x;
				else if (x < minheight)
					minheight = x;
			}

			int size = (int)Math.Sqrt((double)values.Length);

			Bitmap bmp = new System.Drawing.Bitmap(size, size);

			for(int x = 0; x < size; x++)
				for (int y = 0; y < size; y++)
				{
					double percent = (-minheight + values[x, y]) / (-minheight + maxheight);
					Color col;

					if(percent < 0.25)
						col = Color.FromArgb(0, 0, (int)(255 * percent));
					else
						col = Color.FromArgb((int)(255 * percent), (int)(255 * percent), (int)(255 * percent));
					

					bmp.SetPixel(x, y, col);
				}

			pbMain.Image = bmp;
		}

		private void DisplayArray_Load(object sender, EventArgs e)
		{
			
		}
	}
}
