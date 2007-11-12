package org.hackystat.devsite.buildreport;

import java.io.File;
import java.io.FileInputStream;
import java.util.Collection;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.TreeMap;


/**
 * Build report for a particular build configuration.
 *
 * @author Qin Zhang
 * @version $Id: test.java,v 1.1.1.1 2005/08/19 00:58:21 qzhang Exp $
 *
 * @todo investigate whether cache is necessary.
 */
public class BuildReport {
  
  private DailyBuildReports parent;
  private File reportDir;

  /**
   * Creates <code>BuildReport</code>.
   * 
   * @param parent The <code>DailyBuildReports</code> object which owns this instance.
   * @param reportDir The directory where build report for a configuration is stored.
   * 
   * @throws BuildReportException If reportDir is not a directory.
   */
  BuildReport(DailyBuildReports parent, File reportDir) throws BuildReportException {
    this.parent = parent;
    if (!reportDir.isDirectory()) {
      throw new BuildReportException("Cannot find build report in "
                                     + reportDir.getAbsolutePath());
    }
    this.reportDir = reportDir;
  }

  /**
   * Creates <code>BuildReport</code> for the specified build configuration.
   *
   * @param parent The <code>DailyBuildReports</code> object which owns this instance.
   * @param parentDir The directory under which build reports are stored by configuration name.
   * @param buildConfigurationName The name of build configuration.
   * 
   * @throws BuildReportException If the configuration does not exist.
   */
  BuildReport(DailyBuildReports parent, File parentDir, String buildConfigurationName) 
      throws BuildReportException {
    this(parent, new File(parentDir, buildConfigurationName));
  }

  /**
   * Gets build configuration name.
   * 
   * @return The name of the build configuration.
   */
  public String getConfigurationName() {
    return this.reportDir.getName();
  }

  /**
   * Gets the date of this report. Be careful that month in <code>java.util.Date</code>
   * is 0 indexed, while month in this class is 1 indexed.
   * 
   * @return The date.
   */
  public Date getDate() {
    return this.parent.getDate();
  }
  
  /**
   * Gets all sub-report names. Sub-reports are generated in build run.
   * Some examples are ant report, bcml report, test report, etc.
   *
   * @return A collection sub-report names.
   */
  public Collection getSubReportNames() {
    //just sub directory names under this.reportDir
    File[] files = this.reportDir.listFiles();
    List list = new LinkedList();
    int length = files.length;
    for (int i = 0; i < length; i++) {
      if (files[i].isDirectory()) {
        list.add(files[i].getName());
      }
    }
    
    return list;
  }

  /**
   * Gets a collection of <code>XmlHtmlFilePair</code> by report type.
   *
   * @param subReportType The type of subreport.
   * @return The collection of <code>XmlHtmlFilePair</code>.
   */
  public Collection getXmlHtmlFilePairs(String subReportType) {
    //subReportName is just sub-directory name under this.reportDir
    File dir = new File(this.reportDir, subReportType);
    Map map = new TreeMap();

    if (dir.isDirectory()) {
      File[] files = dir.listFiles();
      int length = files.length;
      for (int i = 0; i < length; i++) {
        File file = files[i];
        if (file.isFile()) {
          //handle xml file
          String fileName = file.getName();
          if (fileName.toLowerCase().endsWith(".xml")) {
            String key = fileName.substring(0, fileName.length() - 4);
            XmlHtmlFilePair pair = (XmlHtmlFilePair) map.get(key);
            if (pair == null) {
              map.put(key, new XmlHtmlFilePair(key, file, null));
            }
            else {
              pair.setXmlFile(file);
            }
          }
        }
        else if (file.isDirectory()) {
          //handle index.htm or index.html in the directory
          File htmlFile = new File(file, "index.html");
          if (!htmlFile.isFile()) {
            htmlFile = new File(file, "index.htm");
          }
          if (!htmlFile.isFile()) {
            htmlFile = null;
          }

          if (htmlFile != null) {
            String key = file.getName();
            XmlHtmlFilePair pair = (XmlHtmlFilePair) map.get(key);
            if (pair == null) {
              map.put(key, new XmlHtmlFilePair(key, null, htmlFile));
            }
            else {
              pair.setHtmlFile(htmlFile);
            }
          }
        }
      }
    }

    //-> LOCC task changed, we no longer use csv file any more. -Cedric 2004/12/08
    /*
    //EXCEPTION STARTS
    //check for exception, sub-report type specific knowledge required.
    //currently, only locc report is exception, it contains csv files.
    if ("locc".equals(subReportType)) {
      File loccDir = new File(this.reportDir, subReportType);
      if (loccDir.isDirectory()) {
        File[] files = loccDir.listFiles();
        int length = files.length;
        for (int i = 0; i < length; i++) {
          String fileName = files[i].getName();
          if (files[i].isFile() && fileName.toLowerCase().endsWith(".csv")) {
            String key = fileName.substring(0, fileName.lastIndexOf('.'));
            Object val = map.get(key);
            if (val == null) {
              map.put(key, new XmlHtmlFilePair(key, null, files[i]));
            }
          }
        }
      }
    }
    //EXCEPTION ENDS
    */
    return map.values();
  }

  /**
   * Gets files in the top level directory where this report reside.
   * @param suffix File suffix. If null, all files will be returned.
   * @return A collection of files as required.
   */
  public Collection getTopLevelFiles(String suffix) {
    LinkedList list = new LinkedList();

    File[] files = this.reportDir.listFiles();
    int length = files.length;
    for (int i = 0; i < length; i++) {
      File file = files[i];
      if (file.isFile()) {
        if (suffix == null || files[i].getName().endsWith(suffix)) {
          list.add(file);
        }
      }
    }
    return list;
  }

  /**
   * Gets file by name.
   * @param relativeFileName Relative file name.
   * @return The file, or null if the file does not exist.
   */
  public File getFile(String relativeFileName) {
    File file = new File(this.reportDir, relativeFileName);
    return file.exists() ? file : null;
  }

  /**
   * Gets the detailed description for this build configuration.
   * @return The detailed description.
   */
  public String getConfigurationDescription() {
    String description = null;
    File file = this.getFile("hackystat.properties");

    if (file != null) {
      try {
        Properties properties = new Properties();
        properties.load(new FileInputStream(file));
        description = properties.getProperty("build.configuration.description");
      }
      catch (Exception ex) {
      //ignore
      }
    }

    return (description == null) ? "No description" : description;
  }
}