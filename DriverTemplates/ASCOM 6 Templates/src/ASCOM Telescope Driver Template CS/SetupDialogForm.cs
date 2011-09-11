using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;

namespace ASCOM.$safeprojectname$
{
	[ComVisible(false)]					// Form not registered for COM!
	public partial class SetupDialogForm : Form
	{
		public SetupDialogForm()
		{
			InitializeComponent();
			// TODO initialise the dialog from the settings, e.g.
			string comPort = Properties.Settings.Default.ComPort;
			ASCOM.Utilities.Serial serial = new Utilities.Serial();
			comboBoxComPort.Items.Clear();
			foreach (var item in serial.AvailableCOMPorts)
			{
				comboBoxComPort.Items.Add(item);
				if (item == comPort)
					comboBoxComPort.SelectedIndex = comboBoxComPort.Items.Count - 1;
			}
		}

		private void cmdOKClick(object sender, EventArgs e)
		{
			Properties.Settings.Default.ComPort = (string)comboBoxComPort.SelectedItem;
			Properties.Settings.Default.Save();
			Close();
		}

		private void cmdCancelClick(object sender, EventArgs e)
		{
			Properties.Settings.Default.Reload();
			Close();
		}

		private void BrowseToAscom(object sender, EventArgs e)
		{
			try {
				System.Diagnostics.Process.Start("http://ascom-standards.org/");
			} catch (System.ComponentModel.Win32Exception noBrowser) {
				if (noBrowser.ErrorCode == -2147467259)
					MessageBox.Show(noBrowser.Message);
			} catch (System.Exception other) {
				MessageBox.Show(other.Message);
			}
		}
	}
}