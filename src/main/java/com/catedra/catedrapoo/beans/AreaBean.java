package com.catedra.catedrapoo.beans;

public class AreaBean {
    private int id;
    private String prefix;
    private String name;
    private BasicUserBean boss;
    private BasicUserBean dev_boss;

    public AreaBean(int id, String prefix, String name, BasicUserBean boss, BasicUserBean dev_boss) {
        this.id = id;
        this.prefix = prefix;
        this.name = name;
        this.boss = boss;
        this.dev_boss = dev_boss;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getPrefix() {
        return prefix;
    }

    public void setPrefix(String prefix) {
        this.prefix = prefix;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BasicUserBean getBoss() {
        return boss;
    }

    public void setBoss(BasicUserBean boss) {
        this.boss = boss;
    }

    public BasicUserBean getDev_boss() {
        return dev_boss;
    }

    public void setDev_boss(BasicUserBean dev_boss) {
        this.dev_boss = dev_boss;
    }
}
