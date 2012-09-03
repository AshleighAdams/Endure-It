namespace MapGen
{
    partial class DisplayArray
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
			this.pbMain = new System.Windows.Forms.PictureBox();
			((System.ComponentModel.ISupportInitialize)(this.pbMain)).BeginInit();
			this.SuspendLayout();
			// 
			// pbMain
			// 
			this.pbMain.Dock = System.Windows.Forms.DockStyle.Fill;
			this.pbMain.Location = new System.Drawing.Point(0, 0);
			this.pbMain.Name = "pbMain";
			this.pbMain.Size = new System.Drawing.Size(1008, 1008);
			this.pbMain.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
			this.pbMain.TabIndex = 0;
			this.pbMain.TabStop = false;
			// 
			// DisplayArray
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(1008, 1008);
			this.Controls.Add(this.pbMain);
			this.Name = "DisplayArray";
			this.Text = "DisplayArray";
			this.Load += new System.EventHandler(this.DisplayArray_Load);
			((System.ComponentModel.ISupportInitialize)(this.pbMain)).EndInit();
			this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.PictureBox pbMain;
    }
}