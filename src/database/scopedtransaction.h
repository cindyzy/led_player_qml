// ScopedTransaction.h
#ifndef SCOPEDTRANSACTION_H
#define SCOPEDTRANSACTION_H

#include "DatabaseManager.h"

/**
 * @brief RAII事务管理类
 * 在构造时开始事务，在析构时自动提交或回滚
 */
class ScopedTransaction
{
public:
    /**
     * @brief 构造函数，开始事务
     * @param dbManager 数据库管理器引用
     */
    explicit ScopedTransaction(DatabaseManager& dbManager)
        : m_dbManager(dbManager)
        , m_committed(false)
    {
        m_dbManager.beginTransaction();
    }

    /**
     * @brief 析构函数，如果事务未提交则自动回滚
     */
    ~ScopedTransaction()
    {
        if (!m_committed) {
            m_dbManager.rollbackTransaction();
        }
    }

    // 禁止拷贝
    ScopedTransaction(const ScopedTransaction&) = delete;
    ScopedTransaction& operator=(const ScopedTransaction&) = delete;

    // 允许移动
    ScopedTransaction(ScopedTransaction&& other) noexcept
        : m_dbManager(other.m_dbManager)
        , m_committed(other.m_committed)
    {
        other.m_committed = true;  // 移动后原对象不再管理事务
    }

    /**
     * @brief 手动提交事务
     * @return 提交是否成功
     */
    bool commit()
    {
        if (!m_committed && m_dbManager.commitTransaction()) {
            m_committed = true;
            return true;
        }
        return false;
    }

    /**
     * @brief 手动回滚事务
     * @return 回滚是否成功
     */
    bool rollback()
    {
        if (!m_committed && m_dbManager.rollbackTransaction()) {
            m_committed = true;
            return true;
        }
        return false;
    }

    /**
     * @brief 是否已提交
     */
    bool isCommitted() const { return m_committed; }

private:
    DatabaseManager& m_dbManager;
    bool m_committed;
};

#endif // SCOPEDTRANSACTION_H