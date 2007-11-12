// SLOC (NCLOC) = 335
// CLOC = 28
//                              -*- Mode: Jde -*-
// LOCDiffPanel.java --
// Author          :
// Created On      : Mon Jan 18 14:27:21 1999
// Last Modified By: Joe Dane
// Last Modified On: Wed Sep 29 15:52:43 1999
// RCS: $Id: T02_Inner.java,v 1.1.1.1 2005/08/19 00:58:21 qzhang Exp $
//
// Copyright (c) 1995 Joseph Dane
//
//

package csdl.locc.sys;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.util.Enumeration;

// import java.util.Arrays;
// import java.util.Comparator;

public class LOCDiffPanel extends LOCListPanel {


    private abstract class Pair {
	File oldFile, newFile;
	String oldName, newName;

	Pair(File o, File n) {
	    oldFile = o; newFile = n;
	    try {
		oldName = o.getCanonicalPath();
	    }
	    catch (IOException e) {
		oldName = o.getName();
	    }
	    try {
		newName = n.getCanonicalPath();
	    }
	    catch (IOException e) {
		newName = n.getName();
	    }
	}

	public String toString() {
	    return oldFile.toString() + "/" + newFile.toString();
	}

	abstract void insert();
    }

    private class FilePair extends Pair {
	FilePair(File o, File  n) {
	    super(o, n);
	}
	void insert() {
	    LOCDiffPanel.this.listModel.addElement(this);
	}
    }

    private class DirPair extends Pair {

	ListFilenameFilter filter;

	DirPair(File o, File n, ListFilenameFilter filter) {
	    super(o, n);
	    this.filter = filter;
	}

	void insert() {
	    if (newFile.isDirectory() && oldFile.isDirectory() &&
		newFile.canRead() && oldFile.canRead()) {
		File[] newFiles = LOCListPanel.listFiles(newFile, filter);
		File[] oldFiles = LOCListPanel.listFiles(oldFile);
		Comparator fileNameComparator =
		    new Comparator() {
			public int compare(Object o1, Object o2) {
			    return ((File) o1).getName().compareTo
				((String) ((File) o2).getName());
			}
			// equals from Object
		    };

		Sorts.qs(oldFiles, fileNameComparator);

 		for (int i = 0; i < newFiles.length; i++) {
		    int j = Sorts.binarySearch(oldFiles, newFiles[i],
						fileNameComparator);
		    if (j >= 0) {
			// match found
			(new FilePair(oldFiles[j], newFiles[i])) . insert();
		    }
		}
	    }
	}
    }

    private static class FileTypeAccessory extends JPanel {
	JComboBox filterBox;

	FileTypeAccessory() {
	    setLayout(new GridLayout(2, 1));
	    JPanel p = new JPanel(new GridLayout(2, 1));
	    p.setOpaque(true);
	    p.add(new JLabel("Process files of type "));
	    filterBox = new JComboBox();
	    filterBox.setOpaque(true);
	    filterBox.setBackground(java.awt.Color.white);
	    filterBox.addItem(ListFilenameFilter.javaFilter);
	    filterBox.addItem(ListFilenameFilter.cppFilter);
	    filterBox.addItem(ListFilenameFilter.nullFilter);
	    filterBox.setEditable(false);
	    p.add(filterBox);
	    add(p);
	    add(new JPanel());
	}

	ListFilenameFilter getSelectedFilter() {
	    return (ListFilenameFilter) filterBox.getSelectedItem();
	}

    }

    private class DiffPairDialog extends JDialog implements ActionListener {

	private final Dimension myDimension = new Dimension(400, 200);
	private final int fieldWidth = 200;

	private JTextField oldField, newField;

	private File newFile, oldFile;

	private JFileChooser chooser;

	private boolean directory;

	DiffPairDialog(JFrame parent, String oldName, String newName,
		       String title, boolean directoryp) {
	    super(parent, title, true);

	    this.directory = directoryp;
	    oldFile = newFile = null;

	    setSize(myDimension);
	    JButton oldB = new JButton(oldName);
	    oldB.setActionCommand("old");
	    oldB.addActionListener(this);

	    JButton newB = new JButton(newName);
	    newB.setActionCommand("new");
	    newB.addActionListener(this);

	    Container content = this.getContentPane();

	    content.setLayout(new GridLayout(4, 1));
	    JPanel p = new JPanel(new FlowLayout(FlowLayout.LEFT));
	    p.add(oldB);

	    oldField = new JTextField();
	    oldField.setEditable(false);
	    oldField.setPreferredSize(new Dimension(fieldWidth,
						    oldField.getPreferredSize().height));
	    p.add(oldField);
	    content.add(p);

	    p = new JPanel(new FlowLayout(FlowLayout.LEFT));
	    p.add(newB);

	    newField = new JTextField();
	    newField.setEditable(false);
	    newField.setPreferredSize(new Dimension(fieldWidth,
						    newField.getPreferredSize().height));
	    p.add(newField);
	    content.add(p);

	    String pwd;
	    try {
		pwd = System.getProperty("user.dir");
	    }
	    catch (SecurityException se) {
		pwd = "/";
	    }
	    chooser = new JFileChooser(pwd != null ? pwd : "/");

	    if (directoryp) {
		chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
		chooser.setAccessory(new FileTypeAccessory());
	    }
	    else {
		content.add(new JPanel());
	    }

	    p = new JPanel(new FlowLayout(FlowLayout.CENTER));

	    JButton OK = new JButton("OK");
	    OK.setActionCommand("ok");
	    OK.addActionListener(this);
	    p.add(OK);

	    JButton cancel = new JButton("Cancel");
	    cancel.setActionCommand("cancel");
	    cancel.addActionListener(this);
	    p.add(cancel);

	    content.add(p);
	}

	public void actionPerformed(ActionEvent ae) {
	    String action = ae.getActionCommand();

	    if (action == "new") {
		if (chooser.showOpenDialog(this) == JFileChooser.APPROVE_OPTION) {
		    newFile = chooser.getSelectedFile();
		    newField.setText(newFile.getName());
		}
	    }
	    else if (action == "old") {
		if (chooser.showOpenDialog(this) == JFileChooser.APPROVE_OPTION) {
		    oldFile = chooser.getSelectedFile();
		    oldField.setText(oldFile.getName());
		}
	    }
	    else if (action == "ok") {
		if (oldFile != null && newFile != null) {
		    Pair p;
		    if (directory) {
			ListFilenameFilter filter =
			    ((FileTypeAccessory) chooser.getAccessory()) . getSelectedFilter();
			p = new DirPair(oldFile, newFile, filter);
		    }
		    else {
			p = new FilePair(oldFile, newFile);
		    }
		    p.insert();
		}
		this.setVisible(false);
		oldFile = newFile = null;
		oldField.setText("");
		newField.setText("");
	    }
	    else if (action == "cancel") {
		this.setVisible(false);
		oldFile = newFile = null;
		oldField.setText("");
		newField.setText("");
	    }

	}
    }

    DiffPairDialog fileDialog;

    DiffPairDialog dirDialog;

    LOCDiffPanel(LOCC top) {
	super(top);

	fileDialog = new DiffPairDialog(top, "Old File", "New File",
					"Choose file pair", false);
	dirDialog = new DiffPairDialog(top, "Old Directory", "New Directory",
				       "Choose directory pair", true);

	fileList.setCellRenderer(new cellR());

    }

    public void actionPerformed(ActionEvent ae) {
	String action = ae.getActionCommand();

	// note that the '==' tests are OK (preferred, in fact) here
	// see "intern" for details
	if (action == "file") {
	    postFileDialog();
	}
	else if (action == "dir") {
	    postDirDialog();
	}
	else {
	    super.actionPerformed(ae);
	}
    }

    void postFileDialog() {
	fileDialog.setVisible(true);
    }

    void postDirDialog() {
	dirDialog.setVisible(true);
    }

    int getNumFiles() {
	return listModel.size();
    }

    /**
     * update is a thunk that gets called after each file is processed
     */
    void runPrinter(DiffPrinter printer, Runnable update)
	throws IOException, ParseException {

	String errors = "";
	Enumeration files = listModel.elements();
	boolean sawIOException = false;
	boolean sawParseError = false;

	while (files.hasMoreElements()) {
	    FileInputStream fold = null;
	    FileInputStream fnew = null;
	    try {
		FilePair pair = (FilePair) files.nextElement();
		fnew = new FileInputStream(pair.newFile);
		fold = new FileInputStream(pair.oldFile);
		printer.setCurrentNames(pair.oldName, pair.newName);
		printer.printDiff(fold, fnew);
	    }
	    catch (IOException ioe) {
		errors = errors + newLine + newLine + ioe.getMessage();
		sawIOException = true;
	    }
	    catch (ParseException pe) {
		errors = errors + newLine + newLine + pe.getMessage();
		sawParseError = true;
	    }
	    finally {
		if (fold != null)
		    fold.close();
		if (fnew != null)
		    fnew.close();
		update.run();
	    }
	}
	if (errors.length() > 0) {
	    locc.showMessage(errors);
	}
	if (sawIOException) {
	    throw new IOException();
	}
	if (sawParseError) {
	    throw new ParseException("");
	}
    }

  /**
   * Test method containing local class definitions with no qualifier, an abstract qualifier
   * and a final qualifier, respectively.
   */
  public void testLocalClasses() {
    class LocalNoQualifierClass {}
    abstract class LocalAbstractClass {}
    final class LocalFinalClass {}
  }

    private static class cellR extends JComponent implements ListCellRenderer {

	private static Dimension preferredDim;

	private static int leftOffset = 5;

	private static int tabLength = 5;

	private static int topOffset = 4;

	private Font myFont;

	private FontMetrics myFontMetrics;

	private Dimension mySize;

	private int[] squiggleX;

	private int[] squiggleY;

	private boolean selected;

	private Pair thePair;

	public cellR() {
	    selected = false;
	    mySize = new Dimension(0,0);
	    //	    setBorder(BorderFactory.createEtchedBorder());

	    myFont = new Font("Courier", Font.PLAIN, 12);
	    myFontMetrics = getFontMetrics(myFont);

	    // figure out the coords for the squiggle
	    preferredDim = new Dimension(100, myFontMetrics.getHeight() * 3);
	    squiggleX = new int[4];
	    squiggleY = new int[4];
	    squiggleX[0] = leftOffset + tabLength;
	    squiggleX[1] = leftOffset;
	    squiggleX[2] = leftOffset;
	    squiggleX[3] = leftOffset + tabLength;
	    squiggleY[0] = topOffset;
	    squiggleY[1] = topOffset;
	    squiggleY[2] = topOffset + preferredDim.height - (topOffset * 2);
	    squiggleY[3] = topOffset + preferredDim.height - (topOffset * 2);
	}

	public Component getListCellRendererComponent(JList list,
						      Object val,
						      int index,
						      boolean isSelected,
						      boolean hasFocus) {
	    selected = isSelected;
	    thePair = (Pair) val;
	    return this;
	}

 	protected void paintComponent(Graphics g) {
	    if (thePair != null) {
		Rectangle r = g.getClipBounds();
		if (selected) {
		    g.setColor(selectedBackgroundColor);
		    g.fillRect(r.x, r.y, r.width, r.height);
		    g.setColor(selectedForegroundColor);
		}
		else {
		    g.setColor(unselectedBackgroundColor);
		    g.fillRect(r.x, r.y, r.width, r.height);
		    g.setColor(unselectedForegroundColor);
		}
		g.setFont(myFont);
		getSize(mySize);
		g.drawPolyline(squiggleX, squiggleY, 4);
		g.drawString(thePair.oldName,
			     2*leftOffset, mySize.height / 2 - topOffset);
		g.drawString(thePair.newName,
			     2*leftOffset, mySize.height - 2*topOffset);
	    }
	}

	public Dimension getPreferredSize() {
	    return preferredDim;
	}
    }

}


